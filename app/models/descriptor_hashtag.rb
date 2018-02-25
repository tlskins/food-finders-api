# Inherits from Hashtag - describes a characteristic of a dish to
# substantiate the vote
class DescriptorHashtag < Hashtag
  has_and_belongs_to_many :ratings, index: true
end
