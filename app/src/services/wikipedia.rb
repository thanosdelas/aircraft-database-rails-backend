# frozen_string_literal: true

require 'json'
require 'net/http'
require 'nokogiri'

module Services
  class Wikipedia
    attr_reader :search_result, :summary, :infobox_raw, :infobox_hash, :featured_image, :images

    BASE_API_URL = 'https://en.wikipedia.org/w/api.php'

    def search(search_term)
      params = {
        format: 'json',
        action: 'query',
        origin: '*',
        list: 'search',
        srlimit: 1,
        srsearch: search_term
      }

      uri = URI("#{BASE_API_URL}?#{URI.encode_www_form(params)}")
      response = Net::HTTP.get(uri)
      data = JSON.parse(response)

      @search_result = data['query']['search'][0] if data['query']['search'].length == 1

      @search_result
    end

    # Find summary and infobox for Wikipedia page
    def fetch_page_details # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
      params = {
        format: 'json',
        action: 'query',
        origin: '*',
        prop: 'extracts|revisions',
        exintro: 'true',
        explaintext: true,
        redirects: 1,
        pageids: @search_result['pageid'],
        rvprop: 'content',
        rvsection: 0,
        rvslots: '*'
      }

      uri = URI("#{BASE_API_URL}?#{URI.encode_www_form(params)}")
      response = Net::HTTP.get(uri)
      data = JSON.parse(response)

      if data['query']['pages'].key?(@search_result['pageid'].to_s)
        @summary = data['query']['pages'][@search_result['pageid'].to_s]['extract']
      end

      @infobox_raw = data['query']['pages'][@search_result['pageid'].to_s]['revisions'].first['slots']['main']['*']
      @infobox_raw = Nokogiri::HTML(@infobox_raw).text

      @infobox_hash = infobox_raw_to_hash(@infobox_raw)
      @featured_image = Nokogiri::HTML(@infobox_hash['image']).text

      true
    end

    def extract_featured_image_from_infobox(infobox_raw) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      image = ''

      # The following regular expression matches anything between {{ }}, but ignores
      # subtrings that start and end with the same characters {{ }}.
      # \{\{([^{}]*|(?R))*\}\}
      regex = /\{\{Infobox([^{}]*|#{Regexp.union(/\{\{[^{}]*\}\}/).source})*\}\}/
      find_infobox = infobox_raw[regex, 0]

      return image if find_infobox.nil?

      # Regular expression in gsub, fixes the delimiter "\n|",
      # which may contain one or more spaces between \n and |.
      aircraft_info_raw = find_infobox.gsub(/\n(.*?)\|/, "\n|").split("\n|")

      aircraft_info_raw.each do |entry|
        current_split = entry.split('=', 2)

        if current_split.length == 2 # rubocop:disable Style/Next
          key = current_split[0].strip.squeeze(' ').gsub(/\s+/, '_')

          if key == 'image'
            image = current_split[1].gsub('File:', '').gsub("\n", '').gsub(/<[^>]*>/, '').strip.squeeze(' ')
            break
          end
        end
      end

      image
    end

    def infobox_raw_to_hash(infobox_raw) # rubocop:disable Metrics/AbcSize
      infobox_hash = {}

      aircraft_infoboxes = extract_infoboxes(infobox_raw)

      return infobox_hash if aircraft_infoboxes.length == 0

      aircraft_infoboxes.each do |aircraft_infobox|
        # Remove HTML from infobox string
        aircraft_infobox = Nokogiri::HTML(aircraft_infobox).text

        infobox_entries = aircraft_infobox.split(/\n\s*\|/)
        infobox_entries.shift
        infobox_entries[infobox_entries.length - 1].gsub!("\n}}", '')

        infobox_entries.each do |infobox_entry|
          key, value = infobox_entry.split('=')

          value = '' if value.nil?

          key = key.strip.squeeze(' ').gsub(/\s+/, '_').downcase

          infobox_hash[key] = value.gsub("\n", '').strip.squeeze(' ')
        end
      end

      infobox_hash
    end

    def extract_infoboxes(infobox_raw)
      infoboxes = []

      offset = 0

      while true do
        start_index = infobox_raw.index('{{Infobox', offset)

        break if start_index == nil

        current_index = start_index + 9
        nested_level = 0 # Infobox is at nested level 0

        current_index = current_index + 1
        while infobox_raw[current_index] != nil
          if current_index + 1 == infobox_raw.length && nested_level == 0
            raise 'Reached the end of the string. Provided infobox raw is missing closing double curly braces.'
          end

          # Check for nested opening {{
          if infobox_raw[current_index] == '{' && infobox_raw[current_index + 1] == '{'
            nested_level += 1
          end

          # Check for nested closing {{
          if infobox_raw[current_index] == '}' && infobox_raw[current_index + 1] == '}'
            if nested_level == 0
              current_index = current_index + 1
              break
            end

            nested_level -= 1
          end

          current_index = current_index + 1
        end

        infoboxes.push(infobox_raw[start_index..current_index])

        offset = start_index + 1
      end

      infoboxes
    end

    def find_aircraft_types_in_infobox(infobox_hash)
      matches = []
      possible_infobox_keys = [
        'type',
        'aircraft_type',
        'aircraft_role'
      ]

      # Parse only those wrapped in [[]]
      possible_infobox_keys.each do |infobox_type_key|
        current_matches = infobox_hash[infobox_type_key].scan(/\[\[(.*?)\]\]/) if !infobox_hash[infobox_type_key].nil?

        matches = matches + current_matches if current_matches.is_a?(Array)
      end

      # Accept plain text, if there are no matches.
      if matches.length == 0
        possible_infobox_keys.each do |infobox_type_key|
          current_matches = infobox_hash[infobox_type_key] if !infobox_hash[infobox_type_key].nil?

          matches = matches + [[current_matches]] if current_matches.is_a?(String)
        end
      end

      matches
    end

    def find_images
      image_urls(image_filenames)
    end

    private

    def image_filenames # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      images = []

      params = {
        format: 'json',
        action: 'query',
        origin: '*',
        imlimit: '50',
        prop: 'images',
        titles: @search_result['title']
      }

      uri = URI("#{BASE_API_URL}?#{URI.encode_www_form(params)}")
      response = Net::HTTP.get(uri)
      data = JSON.parse(response)

      if data['query']['pages'].key?(@search_result['pageid'].to_s) &&
         data['query']['pages'][@search_result['pageid'].to_s].key?('images')

        data['query']['pages'][@search_result['pageid'].to_s]['images'].each do |image|
          images.push(image['title'])
        end
      end

      images
    end

    def image_urls(filenames) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      urls = []
      urls_only = [] # Use to keep track of URLs, to skip duplicates.

      params = {
        format: 'json',
        action: 'query',
        origin: '*',
        prop: 'imageinfo',
        iiprop: 'url|extmetadata',
        titles: filenames.join('|')
      }

      uri = URI("#{BASE_API_URL}?#{URI.encode_www_form(params)}")
      response = Net::HTTP.get(uri)
      data = JSON.parse(response)

      return urls if !data.key?('query') ||
                     !data['query'].key?('pages')

      data['query']['pages'].each_value do |image|
        next if urls_only.include?(image['imageinfo'][0]['url']) # Skip duplicate URLs

        next if image['imageinfo'].length != 1 ||
                /.svg/i.match(image['imageinfo'][0]['url']) ||
                /.tif/i.match(image['imageinfo'][0]['url']) ||
                /.gif/i.match(image['imageinfo'][0]['url']) ||
                /.ogv/i.match(image['imageinfo'][0]['url']) ||
                /.ogg/i.match(image['imageinfo'][0]['url']) ||
                /.webm/i.match(image['imageinfo'][0]['url']) ||
                /flag/i.match(image['imageinfo'][0]['url']) ||
                /edit/i.match(image['imageinfo'][0]['url']) ||
                /commons-logo/i.match(image['imageinfo'][0]['url']) ||
                /globe_content/i.match(image['imageinfo'][0]['url']) ||
                /question_mark/i.match(image['imageinfo'][0]['url']) ||
                /Question_book/i.match(image['imageinfo'][0]['url']) ||
                /apps_kaboodle/i.match(image['imageinfo'][0]['url']) ||
                /support_vote/i.match(image['imageinfo'][0]['url']) ||
                /Wiki_letter/i.match(image['imageinfo'][0]['url']) ||
                /Aviacionavion/i.match(image['imageinfo'][0]['url']) ||
                /video_camera/i.match(image['imageinfo'][0]['url']) ||
                /Maple Leaf (from roundel)/i.match(image['imageinfo'][0]['url'])

        urls_only.push(image['imageinfo'][0]['url'])

        build_image_to_collect = {
          url: image['imageinfo'][0]['url'],
          filename: image['title']
        }

        if image['imageinfo'][0]['extmetadata'].key?('ImageDescription') &&
           image['imageinfo'][0]['extmetadata']['ImageDescription'].key?('value')

          build_image_to_collect[:description] = image['imageinfo'][0]['extmetadata']['ImageDescription']['value']
        end

        urls.push(build_image_to_collect)
      end

      urls
    end
  end
end
