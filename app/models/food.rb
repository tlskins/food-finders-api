class Food
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :name, type: String
  field :active_best_award, type: Boolean, default: false

  has_many :votes

  # Fields that are required in order to have a valid Food.
  validates :name, presence: true, uniqueness: true

  index({ name: 1 }, { background: true, unique: true })

end
