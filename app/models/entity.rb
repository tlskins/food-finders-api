class Entity
  include Mongoid::Document
  include Mongoid::Timestamps

  field :business, type: Hash
  field :vote_totals, type: Array

  # TODO - create business id unique index

  has_many :votes

  def name
    business[:name] if business.present?
  end

  def calculate_vote_totals
    # TODO - need to find a way to perform this aggregation without null _id so no array select necessary
    vote_totals = votes.collection.aggregate( [
      { "$group" => { "_id" => "$food_name", "count" => { "$sum" => 1 } } }
    ]).entries.select { |entry| entry["_id"].present? }
    update_attribute(:vote_totals, vote_totals)
  end
end
