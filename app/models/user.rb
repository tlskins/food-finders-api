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
  has_one(
    :follower_tracker,
    as: :followable,
    class_name: 'FollowTracker',
    autobuild: true,
    autosave: true
  )
  has_one(
    :following_tracker,
    as: :followable,
    class_name: 'FollowTracker',
    autobuild: true,
    autosave: true
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

  def publish_draft_social_entry
    social_entries.create(text: draft_social_entry.text)
    draft_social_entry.update_attributes(
      text: '',
      tags: [],
      last_submit: Time.now
    )
  end

  def relevant_newsfeed_ids
    newsfeed_items.limit(25).order_by(relevancy: :desc).map(&:action_id)
  end

  def newsfeed(created_after = nil)
    if created_after.present?
      Action.where(
        :$and => [
          { id: { :$in => relevant_newsfeed_ids } },
          { :created_at.gt => created_after }
        ]
      )
    else
      Action.where(id: { :$in => relevant_newsfeed_ids })
    end
  end
end
