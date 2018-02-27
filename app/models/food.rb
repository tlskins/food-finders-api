# Food Model - dishes, foods
class Food
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Taggable
  include Rateable

  has_many(
    :ratings,
    class_name: 'FoodRating',
    inverse_of: :rateable
  )

  # field :vote_totals, type: Array
  #
  # def calculate_vote_totals
  #   vote_totals = votes.collection.aggregate(
  #     [{ :$group =>
  #         { '_id' =>
  #           { entity_name: '$entity_name', hashtag_name: '$hashtag_name' },
  #           'count' => { :$sum => 1 } } }]
  #   ).entries
  #   update_attribute(:vote_totals, vote_totals)
  # end

  # Used to set taggable symbol in tag
  def tagging_symbol
    '^'
  end

  # Used to set a unique public tag identifier
  def tagging_raw_handle
    handlefy(name)
  end
end
