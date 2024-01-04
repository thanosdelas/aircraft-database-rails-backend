# frozen_string_literal: true

require 'json'
require 'net/http'

module Services
  class Wikipedia
    attr_reader :search_result, :summary, :images

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

    def find_summary # rubocop:disable Metrics/MethodLength
      params = {
        format: 'json',
        action: 'query',
        origin: '*',
        prop: 'extracts',
        exintro: 'true',
        explaintext: true,
        redirects: 1,
        pageids: @search_result['pageid']
      }

      uri = URI("#{BASE_API_URL}?#{URI.encode_www_form(params)}")
      response = Net::HTTP.get(uri)
      data = JSON.parse(response)

      if data['query']['pages'].key?(@search_result['pageid'].to_s)
        @summary = data['query']['pages'][@search_result['pageid'].to_s]['extract']
      end

      @summary
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

      data['query']['pages'].each do |_key, image|
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
