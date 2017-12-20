require "http"

class YelpController < ApplicationController

  # Place holders for Yelp Fusion's API key. Grab it
  # from https://www.yelp.com/developers/v3/manage_app
  API_KEY = "xe3EfcwF37qCK0zoQAQBJC--ZYkio-jrNwEqfWIGOza9TYN8rMdSxcSxs7Q2Tzazi_IEIuKnmOg8K8AqLd5YKzz9lPRF-vvQpKWadMn1pNU7aKwwNIvUanLewu02WnYx"

  # Constants, do not change these
  API_HOST = "https://api.yelp.com"
  SEARCH_PATH = "/v3/businesses/search"
  BUSINESS_PATH = "/v3/businesses/"  # trailing / because we append the business id to the path


  DEFAULT_BUSINESS_ID = "yelp-san-francisco"
  DEFAULT_TERM = "dinner"
  DEFAULT_LOCATION = "San Francisco, CA"
  SEARCH_LIMIT = 5

  def search
    url = "#{API_HOST}#{SEARCH_PATH}"

    params = {
      term: DEFAULT_TERM,
      location: DEFAULT_LOCATION,
      limit: SEARCH_LIMIT
    }

    response = HTTP.auth("Bearer #{API_KEY}").get(url, params: params)
    render json: { response: response.parse }
  end

end
