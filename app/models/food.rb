class Food
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Taggable

  field :vote_totals, type: Array

  has_many :votes

  # Used to set taggable symbol in tag
  def tagging_symbol
    "^"
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
