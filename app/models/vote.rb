class Vote
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :food_name, type: String
  field :entity_name, type: String
  field :hashtag_name, type: String

  belongs_to :food, index: true
  belongs_to :entity, index: true
  belongs_to :hashtag, index: true
  belongs_to :user, index: true

  after_save :recalculate_vote_totals
  after_destroy :recalculate_vote_totals

  # Fields that are required in order to have a valid Food.
  validates :food, :entity, :hashtag, :user, presence: true

  def food_id=(params)
    super(params)
    update_relation_name('food')
  end

  def entity_id=(params)
    super(params)
    update_relation_name('entity')
  end

  def hashtag_id=(params)
    super(params)
    update_relation_name('hashtag')
  end

  def entity_business=(params)
    target_entity = Entity.find_by(business_id: params[:id])
    target_entity.update_attributes(business: params) if target_entity.present?
    target_entity ||= Entity.create(business: params)
    self.entity = target_entity
  end

  protected

    def update_relation_name(relation)
      if self.send(relation).present?
        self.send(relation + '_name=', self.send(relation).name)
      else
        self.send(relation + '_name=', '')
      end
    end

    def recalculate_vote_totals
      puts 'self = ' + self.inspect
      if food.present?
        puts 'calling food calculate'
        food.calculate_vote_totals
      end
      if entity.present?
        puts 'calling entity calculate'
        entity.calculate_vote_totals
      end
    end
end
