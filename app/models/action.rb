# Builds newsfeed items
class Action
  include Mongoid::Document
  include Mongoid::Timestamps

  field :conducted_at, type: DateTime
  field :fan_out_status, type: String # Pending, In Progress, Done
  field :metadata, type: Hash # Data synopsis to write to newfeed item
  field :scope, type: String # Followers, All

  # Actor (or author) of the data in action
  belongs_to :actor, polymorphic: true
  # Data target of the action (includes Actionable concern)
  belongs_to :actionable, polymorphic: true

  validates(
    :conducted_at,
    :scope,
    :fan_out_status,
    :actor,
    :actionable,
    presence: true
  )

  after_create :write_actionable_data

  def actionable_type=(params)
    super(params)
    write_actionable_data
  end

  protected

  def write_actionable_data
    self.actor_id = actionable.actor.id
    self.actor_type = actionable.actor.class.name
    self.conducted_at = Time.now
    self.fan_out_status = 'Pending'
    self.scope = actionable.scope
    self.metadata = actionable.metadata
  end
end
