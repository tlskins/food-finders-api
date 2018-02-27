# Provides all the functionality so that an object is rating typeable
module RatingTypeable
  extend ActiveSupport::Concern

  included do
    field :rating_aggregates, type: Array

    has_many :ratings, as: :rating_typeable
  end

  def embeddable_attributes
    attributes
  end
end
