class Food
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :name, type: String
  field :vote_totals, type: Array

  has_many :votes
  has_one :tag, as: :taggable

  validates :name, presence: true, uniqueness: true

  index({ name: 1 }, { background: true, unique: true })

  # Used to set taggable symbol in tag
  def tagging_symbol
    "^"
  end

  # Used to set a unique public tag identifier
  def tagging_raw_handle
    name
  end

  # Used to set taggable symbol in tag
  def tagging_name
    name
  end

  def calculate_vote_totals
    vote_totals = votes.collection.aggregate( [
      { "$group": { "_id": { entity_name: '$entity_name', hashtag_name: '$hashtag_name' },
                    "count": { "$sum" => 1 }
                  }
      }
    ]).entries
    update_attribute(:vote_totals, vote_totals)
  end
end
