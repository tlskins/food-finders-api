# Rating Model - records user preferences
class Rating
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  belongs_to :social_entry, index: true
  belongs_to :ratable, polymorphic: true, index: true # Food
  belongs_to :rater, polymorphic: true, index: true # User
  belongs_to :ratee, polymorphic: true, index: true # Entity
  belongs_to :rating_type_hashtag, index: true # Hashtag (Rating Type)
  has_and_belongs_to_many :rating_metric_hashtags, index: true

  field :embedded_ratable, type: Hash
  field :embedded_rater, type: Hash
  field :embedded_ratee, type: Hash
  field :embedded_rating_type_hashtag, type: Hash
  field :embedded_rating_metric_hashtags, type: Array

  validates :ratable, :rater, :ratee, :rating_type_hashtag, presence: true
end
