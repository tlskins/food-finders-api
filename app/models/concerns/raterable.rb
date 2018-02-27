# Provides all the functionality so that an object is raterable
module Raterable
  extend ActiveSupport::Concern

  included do
    field :rating_aggregates, type: Array

    has_many :ratings, as: :raterable
  end

  def embeddable_attributes
    attributes
  end
end
