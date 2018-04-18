require 'http'

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

# Entity Model - restaurants, chefs, derive from yelp fusion
class Entity
  include Mongoid::Document
  include Mongoid::Timestamps
  include Taggable
  include Rateeable

  has_many(
    :ratings,
    class_name: 'FoodRating',
    inverse_of: :ratee
  )

  field :handle, type: String
  field :yelp_business, type: Hash
  field :yelp_business_id, type: String
  # field :vote_totals, type: Array

  validates :yelp_business_id, uniqueness: true

  index({ yelp_business_id: 1 }, background: true, unique: true)

  def self.yelp_businesses_search(term)
    url = "#{API_HOST}#{SEARCH_PATH}"
    params = {
      term: term,
      location: DEFAULT_LOCATION,
      limit: SEARCH_LIMIT
    }
    HTTP.auth("Bearer #{API_KEY}").get(url, params: params).parse
  end

  def self.yelp_businesses(id)
    url = "#{API_HOST}#{BUSINESS_PATH}#{id}"
    HTTP.auth("Bearer #{API_KEY}").get(url).parse
  end

  # Used to set taggable symbol in tag
  def tagging_symbol
    '@'
  end

  # Used to set a unique public tag identifier
  def tagging_raw_handle
    # If a yelp business is set use its id as the tagging handle
    return yelp_business['id'] if yelp_business.present?
    name
  end

  def self.create_from_yelp(yelp_business_hash)
    entity = Entity.new(yelp_business: yelp_business_hash)
    entity.update_yelp_business_data
    return entity if entity.invalid?
    entity.save
    entity
  end

  def embeddable_attributes
    { _id: id,
      name: name,
      yelp_business_id: yelp_business_id,
      created_at: created_at }
  end

  # def taggable_attributes
  #   yelp_business
  # end

  def update_yelp_business_data
    return if yelp_business.nil?
    self.name = yelp_business['name']
    self.yelp_business_id = yelp_business['id']
  end
end
