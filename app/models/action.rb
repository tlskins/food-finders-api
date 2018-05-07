# Metadata of sociable data
class Action
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic

  # Written to relevancy in the newsfeed item
  field :conducted_at, type: DateTime
  # Pending, In Progress, Done, Error
  field :fan_out_status, type: String, default: 'pending'
  field :metadata, type: Hash # Data synopsis to write to newfeed item
  field :scope, type: String # followers, subscribers

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
      in: %w[followers public subscribers],
      message: 'Not a valid scope'
    }
  )

  before_validation :write_actionable_data
  after_create :fan_out_action_job

  def self.find_by_actionable_id(actionable_id)
    find_by(actionable_id: BSON::ObjectId(actionable_id))
  end

  scope :root_social_entries, lambda {
    where(actionable_type: 'SocialEntry',
          'metadata.parent_social_entry' => nil)
  }

  scope :public_scope, -> { where(scope: 'followers') }

  scope :with_ids, lambda { |ids|
    where(id: { :$in => ids })
  }

  def fan_out
    set(fan_out_status: 'running')
    if scope == 'followers'
      write_to_followers_feed
      write_to_actor_feed
    elsif scope == 'subscribers'
      write_to_subscribers_feed
    end
    set(fan_out_status: 'done')
  rescue StandardError => error
    logger.error 'Error on action fan out - error message: ' + error.message
    set(fan_out_status: 'error')
  end

  def fan_out_action_job
    FanOutJob.perform_now self if fan_out_status == 'pending'
  end

  def write_to_feed(target)
    newsfeed_items.create!(user_id: target.id, relevancy: conducted_at)
  end

  def write_to_followers_feed
    follower_ids = actor.follower_tracker.target_ids
    follower_ids.each do |follower_id|
      newsfeed_items.create(user_id: follower_id, relevancy: conducted_at)
    end
  end

  def write_to_subscribers_feed
    actionable.subscriber_ids.each do |subscriber_id|
      newsfeed_items.create(user_id: subscriber_id, relevancy: conducted_at)
    end
  end

  def write_to_actor_feed
    return unless actor.respond_to?('newsfeed_items')
    # TODO : If newsfeed user association becomes polymorphic change this
    newsfeed_items.create(user_id: actor.id, relevancy: conducted_at)
  end

  def write_actionable_data
    set(
      actor_id: actionable.actor.id,
      actor_type: actionable.actor.class.name,
      conducted_at: Time.now,
      scope: actionable.scope,
      metadata: actionable.metadata
    )
  end
end
