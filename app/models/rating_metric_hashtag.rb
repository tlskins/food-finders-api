# Inherits from Hashtag - describes a characteristic of a dish to
# substantiate the rating
class RatingMetricHashtag < Hashtag
  field :rating_aggregates, type: Array
  field :description, type: String

  belongs_to(
    :parent_metric,
    class_name: 'RatingMetricHashtag',
    index: true,
    optional: true
  )
  has_many(
    :child_metrics,
    class_name: 'RatingMetricHashtag',
    foreign_key: 'parent_metric_id'
  )
  has_and_belongs_to_many :ratings, index: true

  validates :description, presence: true

  def embeddable_attributes
    { _id: _id,
      _type: _type,
      name: name,
      description: description,
      created_at: created_at }
  end
end
