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
    update_food_name
  end

  def food=(params)
    super(params)
    update_food_name
  end

  def entity_id=(params)
    super(params)
    update_attribute(:entity_name, entity.name) if entity.present?
    entity.calculate_vote_totals
  end

  def entity_business=(business_hash)
    target_entity = Entity.where("business.id" => business_hash[:id]).first
    target_entity.business = business_hash if target_entity.present?
    target_entity ||= Entity.create(business: business_hash)
    self.entity = target_entity
  end

  protected

    def update_food_name
      update_attribute(:food_name, food.name) if food.present?
    end

end
