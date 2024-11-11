# frozen_string_literal: true

namespace :aircraft do
  desc "Re-construct infobox JSON from infobox raw"
  task reconstruct_infobox_json_from_infobox_raw: :environment do
    wikipedia = ::Services::Wikipedia.new
    aircraft_all = ::Aircraft.where.not(infobox_raw: nil)

    aircraft_all.each do |aircraft|
      infobox_hash = wikipedia.infobox_raw_to_hash(aircraft.infobox_raw)

      aircraft.infobox_json = infobox_hash.to_json
      aircraft.save
    end
  end

  desc "Extract types from saved infobox"
  task extract_and_save_types_from_saved_infobox: :environment do
    types = []

    wikipedia = ::Services::Wikipedia.new
    aircraft_all = ::Aircraft.where.not(infobox_json: nil)

    aircraft_all.each do |aircraft|
      infobox_hash = JSON.parse(aircraft['infobox_json'])

      matches = wikipedia.find_aircraft_types_in_infobox(infobox_hash)

      next if matches.length == 0

      matches.each do |words_matched|
        words_matched.each do |type|
          words = type.split('|')
          words.each do |word|
            types.push(word.strip.gsub(/ +/, ' ').titleize)
          end
        end
      end
    end

    types = types.uniq.sort

    # Save aggregated aircraft types to a json for inspection.
    File.open(Rails.root.join('tmp', 'aircraft-types.json'), 'w') do |file|
      file.write(types.uniq.sort.to_json)
    end

    # Save aggregated aircraft types to the database.
    types.each do |type|
      create_type = ::Type.new(aircraft_type: type)
      create_type.save
    end
  end

  desc "Attach aircraft to aircraft types"
  task attach_aircraft_to_aircraft_types: :environment do
    wikipedia = ::Services::Wikipedia.new
    types_all = ::Type.all
    aircraft_all = ::Aircraft.where.not(infobox_json: nil)

    aircraft_all.each do |aircraft|
      infobox_hash = JSON.parse(aircraft['infobox_json'])

      matches = wikipedia.find_aircraft_types_in_infobox(infobox_hash)

      next if matches.length == 0

      matches.each do |words_matched|
        words_matched.each do |type|
          words = type.split('|')
          words.each do |word|
            current_aircraft_type = word.strip.gsub(/ +/, ' ').titleize

            find_type = types_all.find do |saved_type|
              saved_type['aircraft_type'] == current_aircraft_type
            end

            if find_type.nil?
              puts "Did not find any match in database types for type: #{current_aircraft_type}"

              next
            end

            aircraft_type = ::AircraftType.new(aircraft: aircraft, type: find_type)
            aircraft_type.save
          end
        end
      end
    end
  end

  desc "Remove HTML from saved data"
  task remove_html_from_saved_data: :environment do
    require 'nokogiri'

    aircraft_list = ::Aircraft.where(wikipedia_info_collected: true)

    aircraft_list.each do |aircraft|
      infobox_json = JSON.parse(aircraft.infobox_json)
      infobox_json.each do |key, value|
        infobox_json[key] = Nokogiri::HTML(value).text
      end

      aircraft.infobox_json = infobox_json.to_json
      aircraft.infobox_raw = Nokogiri::HTML(aircraft.infobox_raw).text
      aircraft.featured_image = Nokogiri::HTML(aircraft.featured_image).text
      aircraft.save
    end
  end

  desc "Delete Images"
  task delete_images: :environment do
    require_relative './data/images-to-delete.rb'

    IMAGES_TO_DELETE.each do |image_to_delete|
      images = ::AircraftImage.where(
        'filename LIKE :image_to_delete',
        {
          image_to_delete: "%#{ ::AircraftImage.sanitize_sql_like(image_to_delete) }%"
        }
      )

      images.each do |image|
        image.delete
      end
    end
  end

  # NOTE: Experimental. Can be used multiple times, after wikipedia_details_import is run.
  #       to replace the model name with an exact match from wikipedia. eg.:
  #       Search term provided to wikipedia is:
  #       "General Dynamics F-16 Fighting Falcon, multirole fighter (Originally General Dynamics)"
  #       but the wikipedia title found is:
  #       "General Dynamics F-16 Fighting Falcon"
  desc "Replace aircraft model with saved wikipedia title"
  task replace_aircraft_model_with_saved_wikipedia_title: :environment do
    abort('Disabled')

    aircraft_list = ::Aircraft.where(wikipedia_info_collected: true)

    collect_mismatches = []

    aircraft_list.each do |aircraft|
      if aircraft.wikipedia_title != aircraft.model
        collect_mismatches.push({
          searched: aircraft.model,
          found: aircraft.wikipedia_title
        })

        puts "Replacing: #{aircraft.model} with #{aircraft.wikipedia_title}"
        aircraft.model = aircraft.wikipedia_title

        begin
          aircraft.save
        rescue ActiveRecord::RecordNotUnique
          images = ::AircraftImage.where(aircraft_id: aircraft.id)
          images.each do |image|
            image.delete
          end

          aircraft.delete
        end
      end
    end
  end

  desc "Search wikipedia by aircraft model and save data for later inpesction"
  task wikipedia_details_import: :environment do
    # Use to debug SQL queries
    # ActiveRecord::Base.logger = Logger.new(STDOUT)

    wikipedia = ::Services::Wikipedia.new

    aircraft_list = ::Aircraft.where(wikipedia_info_collected: false)

    #
    # Fetch and import
    #
    aircraft_list.each do |aircraft|
      puts "\n\n[*] Collecting information from Wikipedia for: #{aircraft.id}, #{aircraft.model}\n"
      result = wikipedia.search(aircraft.model)
      snippet = result['snippet']

      # Fetch and parse infobox and summary
      unless wikipedia.fetch_page_details
        puts "[!] Could not find wikipedia page details; aborting."
        abort
      end

      if result['title'] != aircraft.model
        result_title_parts = result['title'].split(' ')
        aircraft_model_parts = aircraft.model.split(' ')
        intersection = result_title_parts & aircraft_model_parts

        puts result.to_json
        puts "\n\nThe wikipedia title found does match the provided model name: \nfound: #{result['title']} \nsearched: #{aircraft.model}\n\n"

        if intersection.join(' ') == result['title'] ||
           intersection.length >= 2 ||
           result['title'].downcase == aircraft.model.downcase
          puts "Intersection: #{intersection}. Replacing model name with wikipedia title: #{result['title']}"
          sleep 3

          check_if_aircraft_exists = ::Aircraft.find_by(model: result['title'])
          if !check_if_aircraft_exists.nil?
            ::AircraftImage.where(aircraft_id: aircraft.id).delete_all
            ::AircraftType.where(aircraft_id: aircraft.id).delete_all
            aircraft.delete

            next
          end

          # Replace model with found wikipedia title
          aircraft.model = result['title']
        else
          raise 'The wikipedia title found is not equal to the intersection. Aborting'
        end
      end

      summary = wikipedia.summary
      infobox_raw = wikipedia.infobox_raw
      infobox_json = wikipedia.infobox_hash.to_json

      # NOTE: Featured images are not always saved inside images.
      #       Find a way to retrieve featured image information, and save it to images.
      #       images.map { |entry| entry[:filename] }.include?(featured_image)
      featured_image = wikipedia.featured_image
      images = wikipedia.find_images

      # Assign details to model
      aircraft.wikipedia_title = result['title']
      aircraft.wikipedia_page_id = result['pageid']
      aircraft.snippet = result['snippet']
      aircraft.infobox_raw = infobox_raw if infobox_raw.present?
      aircraft.infobox_json = infobox_json if infobox_json.present?
      aircraft.featured_image = featured_image if featured_image.present?
      aircraft.description = summary if summary.present?

      puts "[*] Wikipedia details fetched; importing ..."

      # Skip existing images. Note that the same image is allowed
      # for different aircraft (unique key combination: url, aircraft_id).
      # BUG: There are results on wikipedia that may have same url for different
      #      image filenames. Make them unique before saving images.
      existing_image_urls = aircraft.images.to_a.map { |i| i.url }
      images.each do |image|
        next if existing_image_urls.include?(image[:url])

        image = aircraft.images.build(image)
      end

      begin
        aircraft.save!
        aircraft.update!(wikipedia_info_collected: true)

      rescue ActiveRecord::RecordInvalid => error
        puts "\n\n[!] Failed with error: #{error.inspect}"
        puts "\n\nWhile importing images for aircraft with id: #{aircraft.id}, and model: #{aircraft.model}\n\n"
        puts aircraft.inspect
        puts "\n\n"
        raise
      end

      puts "[*] Saved.\n\n"
    end
  end
end
