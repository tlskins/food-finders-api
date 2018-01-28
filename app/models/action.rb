# Metadata of sociable data
class Action
  include Mongoid::Document
  include Mongoid::Timestamps

  # Written to relevancy in the newsfeed item
  field :conducted_at, type: DateTime
  field :fan_out_status, type: String # Pending, In Progress, Done, Error
  field :metadata, type: Hash # Data synopsis to write to newfeed item
  field :scope, type: String # Followers, All

  # Actor (or author) of the data in action
  belongs_to :actor, polymorphic: true
  # Data target of the action (includes Actionable concern)
  belongs_to :actionable, polymorphic: true

  has_many :newsfeed_items

  validates(
    :conducted_at,
    :scope,
    :fan_out_status,
    :actor,
    :actionable,
    presence: true
  )
  validates(
    :fan_out_status,
    inclusion: {
      in: %w[pending running done error],
      message: 'Not a valid fan out status'
    }
  )
  validates(
    :scope,
    inclusion: {
      in: %w[followers all],
      message: 'Not a valid scope'
    }
  )

  after_create :write_actionable_data

  def actionable_type=(params)
    super(params)
    write_actionable_data
  end

  def fan_out
    update_attributes(fan_out_status: 'running')
    follower_ids = actor.follower_tracker.target_ids
    follower_ids.each do |follower_id|
      newsfeed_items.create(user_id: follower_id, relevancy: conducted_at)
    end
    update_attributes(fan_out_status: 'done')
  rescue StandardError => error
    logger.error 'Error on action fan out - error message: ' + error.message
    update_attributes(fan_out_status: 'error')
  end

  protected

  def write_actionable_data
    self.actor_id = actionable.actor.id
    self.actor_type = actionable.actor.class.name
    self.conducted_at = Time.now
    self.fan_out_status = 'pending'
    self.scope = actionable.scope
    self.metadata = actionable.metadata
  end
end
