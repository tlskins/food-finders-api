class User
  include Mongoid::Document
  include Mongoid::Timestamps

  field :user_name, type: String
  field :handle, type: String
  field :first_name, type: String
  field :last_name, type: String

  has_many :votes
  has_one :tag, as: :taggable

  embeds_one :draft_social_entry, as: :embeddable_social_entry, class_name: 'EmbeddedSocialEntry'

  # TODO - username validitions on special chars, spaces
  validates :user_name, presence: true, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  index({ user_name: 1 }, { background: true, unique: true })

  # Used to set taggable symbol in tag
  def tagging_symbol
    "@"
  end

  # Used to set a unique public tag identifier
  def tagging_raw_handle
    # If user has picked a to handle to use return that
    return handle if handle.present?

    user_name
  end

  # Used to set taggable symbol in tag
  def tagging_name
    user_name
  end
end
