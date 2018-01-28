# User Model - user persistence
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include Taggable

  field :handle, type: String
  field :first_name, type: String
  field :last_name, type: String

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

  # Used to set taggable symbol in tag
  def tagging_symbol
    '@'
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
