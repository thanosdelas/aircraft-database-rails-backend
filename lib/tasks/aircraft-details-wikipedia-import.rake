# frozen_string_literal: true

namespace :aircraft do
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

      summary = wikipedia.summary
      infobox_raw = wikipedia.infobox_raw
      infobox_hash = wikipedia.infobox_hash
      featured_image = wikipedia.featured_image

      images = wikipedia.find_images

      # Assign details to model
      aircraft.wikipedia_title = result['title']
      aircraft.snippet = result['snippet']
      aircraft.infobox_raw = infobox_raw if infobox_raw.present?
      aircraft.infobox_hash = infobox_hash if infobox_hash.present?
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
