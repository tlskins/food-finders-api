class Entity
  include Mongoid::Document
  include Mongoid::Timestamps
  include Taggable

  field :handle, type: String
  field :yelp_business, type: Hash
  field :yelp_business_id, type: String
  field :vote_totals, type: Array

  has_many :votes

  validates :yelp_business_id, uniqueness: true

  index({ yelp_business_id: 1 }, { background: true, unique: true })

  # Used to set taggable symbol in tag
  def tagging_symbol
    "@"
  end

  # Used to set a unique public tag identifier
  def tagging_raw_handle
    # If user has picked a to handle to use return that
    return handle if handle.present?

    # If a yelp business is set use its id as the tagging handle
    if yelp_business.present?
      return yelp_business[:id]
    end
  end

  def yelp_business=(params)
    super(params)
    update_yelp_business_data
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

    def update_yelp_business_data
      if yelp_business.present?
        self.name = yelp_business[:name]
        self.yelp_business_id = yelp_business[:id]
      else
        # If removing a business relation only delete the business_id, name should stay the same
        self.yelp_business_id = ''
      end
    end
end
