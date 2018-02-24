class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include Taggable

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable

  ## Database authenticatable
  field :email,              type: String, default: ''
  field :encrypted_password, type: String, default: ''

  ## Recoverable
  field :reset_password_token,   type: String
  field :reset_password_sent_at, type: Time

  ## Rememberable
  field :remember_created_at, type: Time

  ## Trackable
  field :sign_in_count,      type: Integer, default: 0
  field :current_sign_in_at, type: Time
  field :last_sign_in_at,    type: Time
  field :current_sign_in_ip, type: String
  field :last_sign_in_ip,    type: String

  ## Confirmable
  field :confirmation_token,   type: String
  field :confirmed_at,         type: Time
  field :confirmation_sent_at, type: Time
  field :unconfirmed_email,    type: String # Only if using reconfirmable

  ## Lockable
  # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
  # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
  # field :locked_at,       type: Time

  field :handle, type: String
  field :first_name, type: String
  field :last_name, type: String
  field :followers_count, type: Integer, default: 0
  field :following_count, type: Integer, default: 0

  has_many :actions, as: :actor
  has_many :newsfeed_items
  has_many :votes
  belongs_to(
    :follower_tracker,
    class_name: 'FollowTracker',
    autobuild: true,
    autosave: true,
    dependent: :destroy
  )
  belongs_to(
    :following_tracker,
    class_name: 'FollowTracker',
    autobuild: true,
    autosave: true,
    dependent: :destroy
  )

  has_many :social_entries
  embeds_one(
    :draft_social_entry,
    as: :embeddable_social_entry,
    class_name: 'EmbeddedSocialEntry',
    autobuild: true
  )

  # TODO : name validitions on special chars, spaces
  validates :first_name, presence: true
  validates :last_name, presence: true

  def full_name
    [first_name, last_name].join(' ')
  end

  def follow(target)
    following_tracker.add_target(target)
    target.follower_tracker.add_target(self)
  end

  def following?(target)
    following_tracker.includes_target?(target)
  end

  def unfollow(target)
    following_tracker.remove_target(target)
    target.follower_tracker.remove_target(self)
  end

  def followed_by?(target)
    follower_tracker.includes_target?(target)
  end

  # TODO : move all following functionality to followable concern
  def refresh_friends_count
    update_attributes(
      followers_count: follower_tracker.target_count,
      following_count: following_tracker.target_count
    )
  end

  # Used to set taggable symbol in tag
  def tagging_symbol
    '@'
  end

  # Used to set a unique public tag identifier
  def tagging_raw_handle
    # If unique handle is already chosen use that
    return handle if handle.present?

    handlefy(name)
  end

  def publish_draft_social_entry
    social_entry = social_entries.create(text: draft_social_entry.text)
    social_entry.create_action
    draft_social_entry.update_attributes(
      text: '',
      tags: [],
      last_submit: Time.now
    )
  end

  def relevant_newsfeed_ids
    newsfeed_items.limit(25).order_by(relevancy: :desc).map(&:action_id)
  end

  def match_relationships(user_ids)
    bson_ids = user_ids.map do |id|
      id.class.name == 'String' ? BSON::ObjectId(id) : id
    end
    bson_ids.map do |id|
      { _id: id,
        follower: follower_tracker.target_ids.include?(id) ? 'Yes' : 'No',
        following: following_tracker.target_ids.include?(id) ? 'Yes' : 'No' }
    end
  end

  def newsfeed(created_after = nil)
    actions = Action.where(id: { :$in => relevant_newsfeed_ids })
    if created_after.present?
      actions = actions.where(:created_at.gt => created_after)
    end
    actions.order_by(conducted_at: 'desc')
  end
end
