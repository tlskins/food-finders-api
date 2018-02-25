# Hashtag Model - an arbitrary subject topic
class Hashtag
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Taggable

  # field :vote_totals, type: Array

  # def calculate_vote_totals
  #   vote_totals = votes.collection.aggregate(
  #     [{ :$group =>
  #         { '_id' =>
  #           { entity_name: '$entity_name', food_name: '$food_name' },
  #           'count' => { :$sum => 1 } } }]
  #   ).entries
  #   update_attribute(:vote_totals, vote_totals)
  # end

  # Used to set taggable symbol in tag
  def tagging_symbol
    '#'
  end

  # Used to set a unique public tag identifier
  def tagging_raw_handle
    handlefy(name)
  end
end
