# Provides all the functionality so that an object is rating metrizable
module RatingMetrizable
  extend ActiveSupport::Concern

  included do
    field :rating_aggregates, type: Array
    # has_many :ratings, as: :rating_metrizable
  end

  def embeddable_attributes
    attributes
  end
end
