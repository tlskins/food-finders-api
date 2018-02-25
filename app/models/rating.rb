# Rating Model - record user preferences
class Rating
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :food_name, type: String
  field :entity_name, type: String
  field :ratable_hashtag_name, type: String

  belongs_to :food, index: true
  belongs_to :entity, index: true
  belongs_to :user, index: true
  belongs_to :ratable_hashtag, index: true
  has_and_belongs_to_many :descriptor_hashtags, index: true
  belongs_to :social_entry, index: true

  # after_create :recalculate_vote_totals
  # after_destroy :recalculate_vote_totals

  validates :food, :entity, :user, :ratable_hashtag, presence: true

  # For testing purposes
  # def list_all_pretty
  #   Vote.all.map { |v| puts v.to_s }
  # end

  def to_s
    [entity_name, ratable_hashtag, food_name].join(' - ')
  end

  def food_id=(params)
    super(params)
    update_relation_name('food')
  end

  def entity_id=(params)
    super(params)
    update_relation_name('entity')
  end

  def ratable_hashtag_id=(params)
    super(params)
    update_relation_name('ratable_hashtag')
  end

  def entity_business=(params)
    target_entity = Entity.find_by(business_id: params[:id])
    # Update with yelp data if entity found
    target_entity.update_attributes(business: params) if target_entity.present?
    target_entity ||= Entity.create(business: params)
    self.entity = target_entity
  end

  protected

  def update_relation_name(relation)
    if send(relation).present?
      send(relation + '_name=', send(relation).name)
    else
      send(relation + '_name=', '')
    end
  end

  # def recalculate_vote_totals
  #   food.calculate_vote_totals if food.present?
  #   entity.calculate_vote_totals if entity.present?
  #   ratable_hashtag.calculate_vote_totals if ratable_hashtag.present?
  # end
end
