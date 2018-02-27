# Rating Model - records user preferences
class Rating
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  belongs_to :social_entry, index: true, optional: true
  belongs_to :rateable, polymorphic: true, index: true # Food
  belongs_to :rater, polymorphic: true, index: true # User
  belongs_to :ratee, polymorphic: true, index: true # Entity
  belongs_to :rating_typeable, polymorphic: true, index: true # Hashtag (Rating Type)
  # TODO : Need a polymorphic HBTM solution for mongoid
  has_and_belongs_to_many :rating_metric_hashtags, index: true # Hashtag (Rating Metric)

  field :embedded_rateable, type: Hash
  field :embedded_rater, type: Hash
  field :embedded_ratee, type: Hash
  field :embedded_rating_typeable, type: Hash
  field :embedded_rating_metric_hashtags, type: Array

  validates :rateable, :rater, :ratee, :rating_typeable, presence: true
end
