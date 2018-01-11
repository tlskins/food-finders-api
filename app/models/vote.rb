class Vote
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :food_name, type: String
  field :entity_name, type: String

  belongs_to :food, index: true
  belongs_to :entity, index: true
  belongs_to :user, index: true

  # Fields that are required in order to have a valid Food.
  validates :food, :entity, :user, presence: true

  def food_id=(params)
    super(params)
    update_attribute(:food_name, food.name) if food.present?
  end

  def entity_id=(params)
    super(params)
    # write entity_name on assignment
    update_attribute(:entity_name, entity.name) if entity.present?
    # update entity vote totals
    entity.calculate_vote_totals
  end

end
