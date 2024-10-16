# frozen_string_literal: true

require 'json'
require 'net/http'

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
      @infobox_hash = extract_infobox_raw(@infobox_raw)
      @featured_image = extract_featured_image_from_infobox(@infobox_raw)

      true
    end

    def extract_featured_image_from_infobox(data) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      image = ''

      # The following regular expression matches anything between {{ }}, but ignores
      # subtrings that start and end with the same characters {{ }}.
      # \{\{([^{}]*|(?R))*\}\}
      regex = /\{\{Infobox([^{}]*|#{Regexp.union(/\{\{[^{}]*\}\}/).source})*\}\}/
      find_infobox = data[regex, 0]

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

    def extract_infobox_raw(data) # rubocop:disable Metrics/AbcSize
      collect_entries = {}

      aircraft_infobox = data[/{{Infobox aircraft type(.*?)}}/m, 1]

      return collect_entries if aircraft_infobox.nil?

      aircraft_info_raw = aircraft_infobox.split("\n|")

      aircraft_info_raw.each do |entry|
        current_split = entry.split('=', 2)

        next unless current_split.length == 2

        key = current_split[0].strip.squeeze(' ').gsub(/\s+/, '_')
        collect_entries[key] = current_split[1].gsub("\n", '').strip.squeeze(' ')
      end

      collect_entries
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
                /flag/i.match(image['imageinfo'][0]['url']) ||
                /edit/i.match(image['imageinfo'][0]['url']) ||
                /commons-logo/i.match(image['imageinfo'][0]['url']) ||
                /globe_content/i.match(image['imageinfo'][0]['url']) ||
                /question_mark/i.match(image['imageinfo'][0]['url']) ||
                /Question_book/i.match(image['imageinfo'][0]['url']) ||
                /apps_kaboodle/i.match(image['imageinfo'][0]['url']) ||
                /support_vote/i.match(image['imageinfo'][0]['url']) ||
                /Wiki_letter/i.match(image['imageinfo'][0]['url']) ||
                /Aviacionavion/i.match(image['imageinfo'][0]['url'])

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
