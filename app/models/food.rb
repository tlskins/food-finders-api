# Food Model - dishes, foods
class Food
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Taggable
  include Rateable

  attr_accessor :rating_class

  has_many(
    :ratings,
    class_name: 'FoodRating',
    inverse_of: :rateable
  )

  # Used to set taggable symbol in tag
  def tagging_symbol
    '^'
  end

  # Used to set a unique public tag identifier
  def tagging_raw_handle
    handlefy(name)
  end
end
