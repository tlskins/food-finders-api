# Metadata of sociable data
class Action
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

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

  after_create :write_actionable_data, :write_to_actor_feed, :fan_out_action_job

  def actionable_type=(params)
    super(params)
    write_actionable_data
  end

  # TODO : Fan out needs to work with updates and destroys not just creates
  def fan_out
    update_attributes(fan_out_status: 'running')
    follower_ids = actor.follower_tracker.target_ids
    follower_ids.each do |follower_id|
      newsfeed_items.create(user_id: follower_id, relevancy: conducted_at)
    end
    set(fan_out_status: 'done')
  rescue StandardError => error
    logger.error 'Error on action fan out - error message: ' + error.message
    set(fan_out_status: 'error')
  end

  def fan_out_action_job
    FanOutJob.perform_now self if fan_out_status == 'pending'
  end

  def write_to_actor_feed
    return unless actor.respond_to?('newsfeed_items')
    # TODO : If newsfeed user association becomes polymorphic change this
    newsfeed_items.create(user_id: actor.id, relevancy: conducted_at)
  end

  protected

  def write_actionable_data
    set(
      actor_id: actionable.actor.id,
      actor_type: actionable.actor.class.name,
      conducted_at: Time.now,
      fan_out_status: 'pending',
      scope: actionable.scope,
      metadata: actionable.metadata
    )
  end
end
