# Provides all the functionality so that an object is rating metrizable
module RatingMetrizable
  extend ActiveSupport::Concern

  included do
    field :ratings_aggregates, type: Array
  end

  def ratings
    raise 'ratings not associated'
  end

  def aggregate_ratings
    ratings_aggregates = ratings.collection.aggregate(
      [
        { :$group =>
          { _id:  { rateable_name: '$embedded_rateable.name',
                    ratee_name: '$embedded_ratee.name',
                    rating_type_name: '$embedded_rating_type.name' },
            total: { '$sum' => 1 } } }
      ]
    ).entries
    update_attribute(:ratings_aggregates, ratings_aggregates)
  end

  def embeddable_attributes
    attributes
  end
end
