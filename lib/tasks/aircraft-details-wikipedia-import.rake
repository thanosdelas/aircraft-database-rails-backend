# frozen_string_literal: true

namespace :aircraft do
  desc "Remove HTML from saved data"
  task remove_html_from_saved_data: :environment do
    require 'nokogiri'

    aircraft_list = ::Aircraft.where(wikipedia_info_collected: true)

    aircraft_list.each do |aircraft|
      aircraft.infobox_json = Nokogiri::HTML(aircraft.infobox_json).text
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
    require 'nokogiri'

    # Use to debug SQL queries
    # ActiveRecord::Base.logger = Logger.new(STDOUT)

    wikipedia = ::Services::Wikipedia.new

    aircraft_list = ::Aircraft.where(wikipedia_info_collected: false)

    aircraft_list = ::Aircraft.where(wikipedia_info_collected: true, model: 'Lockheed C-5 Galaxy')

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

      summary = wikipedia.summary
      infobox_raw = wikipedia.infobox_raw
      infobox_json = Nokogiri::HTML(wikipedia.infobox_hash.to_json).text

      # NOTE: Featured images are not always saved inside images.
      #       Find a way to retrieve featured image information, and save it to images.
      #       images.map { |entry| entry[:filename] }.include?(featured_image)
      featured_image = Nokogiri::HTML(wikipedia.featured_image).text
      images = wikipedia.find_images

      # Assign details to model
      aircraft.wikipedia_title = result['title']
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
