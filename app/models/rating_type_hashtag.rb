# Inherits from Hashtag - each social entry is one vote for the hashtag
# which includes a number of other dish descriptor hashtags, as well as an
# entity, food, user
class RatingTypeHashtag < Hashtag
  include RatingTypeable

  has_many(
    :ratings,
    class_name: 'FoodRating',
    inverse_of: :rating_type
  )
end
