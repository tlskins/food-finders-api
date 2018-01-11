class Entity
  include Mongoid::Document
  include Mongoid::Timestamps

  field :business, type: Hash
  field :vote_totals, type: Array

  has_many :votes

  def name
    business[:name] if business.present?
  end

  def calculate_vote_totals
    vote_totals = votes.collection.aggregate( [
      { "$group" => { "_id" => "$food_name", "count" => { "$sum" => 1 } } }
    ]).entries.select { |entry| entry["_id"].present? }
    update_attribute(:vote_totals, vote_totals)
  end
end
