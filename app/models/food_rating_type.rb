# Inherits from Hashtag - each social entry is one vote for the hashtag
# which includes a number of other dish descriptor hashtags, as well as an
# entity, food, user
class FoodRatingType
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Taggable
  include RatingTypeable
  include Hierarchical

  has_many(
    :ratings,
    class_name: 'FoodRating',
    inverse_of: :rating_type
  )

  # Used to set taggable symbol in tag
  def tagging_symbol
    '#'
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
