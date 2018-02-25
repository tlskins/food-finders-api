# Inherits from Hashtag - describes a characteristic of a dish to
# substantiate the rating
class RatingMetricHashtag < Hashtag
  has_many :ratings
end
