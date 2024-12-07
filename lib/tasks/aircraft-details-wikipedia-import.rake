# frozen_string_literal: true

namespace :aircraft do
  desc 'Extract manufacturer groups'
  task extract_manufacturer_groups: :environment do
    manufacturers = ::Manufacturer.all.to_a

    manufacturers.each do |manufacturer|
      manufacturer.manufacturer_group_id = nil
      manufacturer.save!
    end

    ::ManufacturerGroup.all.to_a.each do |group|
      group.delete
    end

    manufacturer_groups = [
      "Airbus",
      "Bell",
      "Boeing",
      "Bombardier",
      "Comac",
      "Dassault Aviation",
      "Embraer",
      "Gulfstream Aerospace",
      "Honda Aircraft Company",
      "Kawasaki",
      "Lockheed Martin",
      "Mc Donnell Douglas",
      "Mitsubishi Heavy Industries",
      "North American",
      "Northrop Grumman",
      "Pilatus Aircraft",
      "Textron Aviation",
      "Tupolev",
      "United Aircraft Corporation",
      "Viking Air",
      "Vought",
      "Antonov",
      "Cessna",
      "Cirrus Aircraft",
      "Diamond Aircraft Industries",
      "Fairchild Dornier",
      "Fokker",
      "General Dynamics",
      "General Atomics",
      "Hughes",
      "Ilyushin",
      "Sukhoi",
      "Yakolev",
      "Raytheon",
      "Short",
      "Yakovlev",
      "Mikoyan",
      "Kaman",
      "Tupolev",
      "Beriev",
      "Ilyushin",
      "BAE Systems",
      "Rockwell",
      "Beechcraft",
      "Kamov",
      "Agusta Westland",
      "Saab",
      "Alenia",
      "British Aerospace",
      "Canadair",
      "Chengdu",
      "De Havilland",
      "Dornier",
      "Eurofighter",
      "Fairchild Aircraft"
    ]

    collect_groups = {}
    manufacturer_groups.each do |manufacturer_group|
      collect_groups[manufacturer_group] = []
    end

    manufacturers.each do |manufacturer|
      manufacturer_groups.each do |manufacturer_group|
        if manufacturer.manufacturer.downcase.include?(manufacturer_group.downcase)
          collect_groups[manufacturer_group].push(manufacturer)
        end
      end
    end

    collect_groups.keys.each do |group_key|
      puts "#{group_key} => #{collect_groups[group_key].length}"

      manufacturers = collect_groups[group_key].map { |e| e.manufacturer }
      manufacturer_group = ::ManufacturerGroup.new(manufacturer_group: group_key, description: manufacturers.to_s)
      manufacturer_group.save!

      collect_groups[group_key].each do |manufacturer|
        manufacturer.manufacturer_group = manufacturer_group
        manufacturer.save!
      end
    end
  end

  desc 'Extract fields from saved infobox'
  task extract_and_save_fields_from_saved_infobox: :environment do
    aircraft_all = ::Aircraft.where("infobox_json LIKE '%first_flight%'")

    # Possible keys to collect:
    #
    # national_origin
    # first_flight
    # introduction
    # status
    # retired
    # number_built
    # developed_from
    # developed_into
    # variants
    # produced
    # unit_cost
    #
    # collect_keys = []
    # aircraft_all.each do |aircraft|
    #   infobox_hash = JSON.parse(aircraft['infobox_json'])
    #   collect_keys += infobox_hash.keys
    # end
    # collect_keys = collect_keys.uniq

    aircraft_all.each do |aircraft|
      infobox_hash = JSON.parse(aircraft['infobox_json'])

      next if infobox_hash['first_flight'].nil?

      year = infobox_hash['first_flight'].match(/\d{4}/)

      if year.nil?
        puts "Could not extract year from: #{infobox_hash['first_flight'].inspect}"

        next
      end

      # aircraft.first_flight = Time.parse(infobox_hash['first_flight'])
      aircraft.first_flight_year = year[0].to_i
      aircraft.first_flight_raw = infobox_hash['first_flight']
      aircraft.save
    end
  end

  desc 'Re-construct infobox JSON from infobox raw'
  task reconstruct_infobox_json_from_infobox_raw: :environment do
    wikipedia = ::Services::Wikipedia.new
    aircraft_all = ::Aircraft.where.not(infobox_raw: nil)

    aircraft_all.each do |aircraft|
      infobox_hash = wikipedia.infobox_raw_to_hash(aircraft.infobox_raw)

      aircraft.infobox_json = infobox_hash.to_json
      aircraft.save
    end
  end

  desc 'Extract manufacturers from saved infobox'
  task extract_and_save_manufacturers_from_saved_infobox: :environment do
    manufacturers = []

    wikipedia = ::Services::Wikipedia.new
    aircraft_all = ::Aircraft.where.not(infobox_json: nil)

    aircraft_all.each do |aircraft|
      infobox_hash = JSON.parse(aircraft['infobox_json'])

      matches = wikipedia.find_aircraft_manufacturers_in_infobox(infobox_hash)

      next if matches.length == 0

      matches.each do |words_matched|
        words_matched.each do |manufacturer|
          words = manufacturer.split('|')
          words.each do |word|
            next if word.include?('{{') || word.include?('}}')

            manufacturers.push(word.strip.gsub(/ +/, ' ').titleize)
          end
        end
      end
    end

    manufacturers = manufacturers.uniq.sort

    # Save aggregated aircraft manufacturers to a json for inspection.
    File.open(Rails.root.join('tmp/aircraft-manufacturers.json'), 'w') do |file|
      file.write(manufacturers.uniq.sort.to_json)
    end

    # Save aggregated aircraft manufacturers to the database.
    created_manufacturers = 0
    manufacturers.each do |manufacturer|
      existing_manufacturer = ::Manufacturer.find_by(manufacturer: manufacturer)

      next if existing_manufacturer != nil

      create_manufacturer = ::Manufacturer.new(manufacturer: manufacturer)
      create_manufacturer.save!

      created_manufacturers = created_manufacturers + 1
    end

    puts "Done. Created #{created_manufacturers} aircraft manufacturers."
  end

  desc 'Attach aircraft to aircraft manufacturers'
  task attach_aircraft_to_aircraft_manufacturers: :environment do
    wikipedia = ::Services::Wikipedia.new
    manufacturers_all = ::Manufacturer.all
    aircraft_all = ::Aircraft.where.not(infobox_json: nil)

    aircraft_all.each do |aircraft|
      infobox_hash = JSON.parse(aircraft['infobox_json'])

      matches = wikipedia.find_aircraft_manufacturers_in_infobox(infobox_hash)

      next if matches.length == 0

      matches.each do |words_matched|
        words_matched.each do |manufacturer|
          words = manufacturer.split('|')
          words.each do |word|
            current_aircraft_manufacturer = word.strip.gsub(/ +/, ' ').titleize

            find_manufacturer = manufacturers_all.find do |saved_manufacturer|
              saved_manufacturer['manufacturer'] == current_aircraft_manufacturer
            end

            if find_manufacturer.nil?
              puts "Did not find any match in database manufacturers for manufacturer: #{current_aircraft_manufacturer}"

              next
            end

            next if aircraft.manufacturers.include?(find_manufacturer)

            aircraft_manufacturer = ::AircraftManufacturer.new(aircraft: aircraft, manufacturer: find_manufacturer)
            aircraft_manufacturer.save
          end
        end
      end
    end
  end

  desc 'Extract types from saved infobox'
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
    File.open(Rails.root.join('tmp/aircraft-types.json'), 'w') do |file|
      file.write(types.uniq.sort.to_json)
    end

    # Save aggregated aircraft types to the database.
    created_types = 0
    types.each do |type|
      existing_type = ::Type.find_by(aircraft_type: type)

      next if existing_type != nil

      create_type = ::Type.new(aircraft_type: type)
      create_type.save!

      created_types = created_types + 1
    end

    puts "Done. Created #{created_types} aircraft types."
  end

  desc 'Attach aircraft to aircraft types'
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

            next if aircraft.types.include?(find_type)

            aircraft_type = ::AircraftType.new(aircraft: aircraft, type: find_type)
            aircraft_type.save
          end
        end
      end
    end
  end

  desc 'Remove HTML from saved data'
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

  desc 'Delete Images'
  task delete_images: :environment do
    require_relative './data/images-to-delete'

    IMAGES_TO_DELETE.each do |image_to_delete|
      images = ::AircraftImage.where(
        'filename LIKE :image_to_delete',
        {
          image_to_delete: "%#{::AircraftImage.sanitize_sql_like(image_to_delete)}%"
        }
      )

      images.each(&:delete)
    end
  end

  # NOTE: Experimental. Can be used multiple times, after wikipedia_details_import is run.
  #       to replace the model name with an exact match from wikipedia. eg.:
  #       Search term provided to wikipedia is:
  #       "General Dynamics F-16 Fighting Falcon, multirole fighter (Originally General Dynamics)"
  #       but the wikipedia title found is:
  #       "General Dynamics F-16 Fighting Falcon"
  desc 'Replace aircraft model with saved wikipedia title'
  task replace_aircraft_model_with_saved_wikipedia_title: :environment do
    abort('Disabled')

    # rubocop:disable Lint/UnreachableCode
    aircraft_list = ::Aircraft.where(wikipedia_info_collected: true)

    collect_mismatches = []

    aircraft_list.each do |aircraft|
      next unless aircraft.wikipedia_title != aircraft.model

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
        images.each(&:delete)

        aircraft.delete
      end
    end
    # rubocop:enable Lint/UnreachableCode
  end

  desc 'Search wikipedia by aircraft model and save data for later inpesction'
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

      raise "Could not find a match for #{aircraft.model}" if result.nil?

      # Fetch and parse infobox and summary
      unless wikipedia.fetch_page_details
        puts '[!] Could not find wikipedia page details; aborting.'
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

      puts '[*] Wikipedia details fetched; importing ...'

      # Skip existing images. Note that the same image is allowed
      # for different aircraft (unique key combination: url, aircraft_id).
      # BUG: There are results on wikipedia that may have same url for different
      #      image filenames. Make them unique before saving images.
      existing_image_urls = aircraft.images.to_a.map(&:url)
      images.each do |image|
        next if existing_image_urls.include?(image[:url])
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
