# Food Model - dishes, foods
class Food
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Taggable
  include Rateable

  field :handle, type: String
  field :description, type: String
  field :synonyms, type: Array

  has_many(
    :ratings,
    class_name: 'FoodRating',
    inverse_of: :rateable
  )

  index({ name: 1 }, background: true, unique: true, drop_dups: true)

  # Used to set taggable symbol in tag
  def tagging_symbol
    '^'
  end

  # Used to set a unique public tag identifier
  def tagging_raw_handle
    handle || name
  end

  def self.rating_class
    FoodRating
  end
end
