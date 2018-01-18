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
    vote_totals = votes.collection.aggregate( [
      { "$group": { "_id": { entity_name: '$entity_name', hashtag_name: '$hashtag_name' },
                    "count": { "$sum" => 1 }
                  }
      }
    ]).entries

    update_attribute(:vote_totals, vote_totals)
  end
end
