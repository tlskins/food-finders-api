class Entity
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :business, type: Hash
  field :business_id, type: String
  field :vote_totals, type: Array

  has_many :votes

  # Fields that are required in order to have a valid Food.
  validates :business_id, uniqueness: true
  validates :name, presence: true, uniqueness: true, length: { minimum: 3, maximum: 20 }

  index({ business_id: 1 }, { background: true, unique: true })
  index({ name: 1  }, { background: true, unique: true, drop_dups: true })

  def business=(params)
    super(params)
    update_business_data
  end

  def calculate_vote_totals
    vote_totals = votes.collection.aggregate( [
      { "$group": { "_id": { food_name: '$food_name', hashtag_name: '$hashtag_name' },
                    "count": { "$sum" => 1 }
                  }
      }
    ]).entries

    update_attribute(:vote_totals, vote_totals)
  end
  
  protected

    def update_business_data
      if business.present?
        self.name = business[:name]
        self.business_id = business[:id]
      else
        # If removing a business relation only delete the business_id, name should stay the same
        self.business_id = ''
      end
    end
end
