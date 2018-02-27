# Provides all the functionality so that an object is rateeable
module Rateeable
  extend ActiveSupport::Concern

  included do
    field :rating_aggregates, type: Array

    has_many :ratings, as: :rateeable
  end

  def embeddable_attributes
    attributes
  end
end
