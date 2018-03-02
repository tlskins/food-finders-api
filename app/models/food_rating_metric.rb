# Inherits from Hashtag - describes a characteristic of a dish to
# substantiate the rating
class FoodRatingMetric
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Taggable
  include RatingMetrizable
  include Hierarchical

  has_many(
    :ratings,
    class_name: 'FoodRating',
    inverse_of: :rating_metrics
  )

  # Used to set taggable symbol in tag
  def tagging_symbol
    '&'
  end

  # Used to set a unique public tag identifier
  def tagging_raw_handle
    handlefy(name)
  end

  def embeddable_attributes
    { _id: _id,
      name: name,
      description: description,
      synonyms: synonyms,
      created_at: created_at }
  end
end
