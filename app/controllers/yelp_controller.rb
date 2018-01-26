require 'http'

# Yelp controller
class YelpController < ApplicationController
  # Place holders for Yelp Fusion's API key. Grab it
  # from https://www.yelp.com/developers/v3/manage_app
  API_KEY = 'xe3EfcwF37qCK0zoQAQBJC--ZYkio-jrNwEqfWIGOza9TYN8rMdSxcSxs7Q2Tzazi_IEIuKnmOg8K8AqLd5YKzz9lPRF-vvQpKWadMn1pNU7aKwwNIvUanLewu02WnYx'.freeze

  # Constants, do not change these
  API_HOST = 'https://api.yelp.com'.freeze
  SEARCH_PATH = '/v3/businesses/search'.freeze
  # trailing / because we append the business id to the path
  BUSINESS_PATH = '/v3/businesses/'.freeze

  DEFAULT_BUSINESS_ID = 'yelp-san-francisco'.freeze
  DEFAULT_TERM = 'dinner'.freeze
  DEFAULT_LOCATION = 'Arlington, VA'.freeze
  SEARCH_LIMIT = 5

  def search
    term = params['term']
    url = "#{API_HOST}#{SEARCH_PATH}"
    params = {
      term: term,
      location: DEFAULT_LOCATION,
      limit: SEARCH_LIMIT
    }

    response = HTTP.auth("Bearer #{API_KEY}").get(url, params: params)
    render json: response.parse
  end
end
