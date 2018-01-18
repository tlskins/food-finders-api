class Food
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :name, type: String
  field :vote_totals, type: Array

  has_many :votes

  # Fields that are required in order to have a valid Food.
  validates :name, presence: true, uniqueness: true

  index({ name: 1 }, { background: true, unique: true })

  def calculate_vote_totals
    # TODO - need to find a way to perform this aggregation without null _id so no array select necessary
    vote_totals = votes.collection.aggregate( [
      { "$group" => { "_id" => "$entity_name", "count" => { "$sum" => 1 } } }
    ]).entries.select { |entry| entry["_id"].present? }
    update_attribute(:vote_totals, vote_totals)
  end

end
