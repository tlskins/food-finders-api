class Entity
  include Mongoid::Document
  include Mongoid::Timestamps

  field :business_id, type: String
  field :business, type: Hash
  field :vote_totals, type: Array

  has_many :votes

  # Fields that are required in order to have a valid Food.
  validates :business_id, presence: true, uniqueness: true

  index({ business_id: 1 }, { background: true, unique: true })

  def business=(params)
    super(params)
    update_attribute(:business_id, business[:id]) if business_id.nil? && business.present?
  end

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
