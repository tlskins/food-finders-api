# Rating Model - records user preferences
class FoodRating
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Ratingable

  belongs_to :social_entry, index: true, optional: true
  belongs_to :rateable, class_name: 'Food', inverse_of: :ratings, index: true
  belongs_to :rater, class_name: 'User', inverse_of: :ratings, index: true
  belongs_to :ratee, class_name: 'Entity', inverse_of: :ratings, index: true
  belongs_to(
    :rating_type,
    class_name: 'FoodRatingType',
    inverse_of: :ratings,
    index: true
  )
  has_and_belongs_to_many(
    :rating_metrics,
    class_name: 'FoodRatingMetric',
    inverse_of: :ratings,
    index: true
  )
end
