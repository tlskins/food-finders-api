# Provides all the functionality so that an object is rateable (Food)
module Rateable
  extend ActiveSupport::Concern

  included do
    field :ratings_aggregates, type: Array
  end

  def ratings
    raise 'ratings not associated'
  end

  def rating_class
    raise 'rating class not set!'
  end

  def aggregate_ratings
    ratings_aggregates = ratings.collection.aggregate(
      [
        { :$unwind => '$embedded_rating_metrics' },
        { :$group =>
          { _id:  { ratee_name: '$embedded_ratee.name',
                    rating_type_name: '$embedded_rating_type.name',
                    rating_metric_name: '$embedded_rating_metrics.name' },
            total: { '$sum' => 1 } } }
      ]
    ).entries
    update_attribute(:ratings_aggregates, ratings_aggregates)
  end

  def embeddable_attributes
    attributes
  end
end
