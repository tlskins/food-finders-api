# Entries in each user's newsfeed
class NewsfeedItem
  include Mongoid::Document
  include Mongoid::Timestamps

  # Use simple recency for relevancy for now
  field :relevancy, type: DateTime

  # Newsfeed owner
  belongs_to :user
  # Social meta data
  belongs_to :action

  has_many :newsfeed_items
end
