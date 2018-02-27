# Provides all the functionality so that an object is rateable
module Rateable
  extend ActiveSupport::Concern

  included do
    include Mongoid::Document
    field :rating_aggregates, type: Array

    has_many :ratings, as: :rateable
  end

  def embeddable_attributes
    attributes
  end
end
