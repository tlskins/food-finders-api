# Social Entry Model - a post or tweet
class SocialEntry
  include Mongoid::Document
  include Mongoid::Timestamps
  include Actionable
  include Parseable

  field :text, type: String

  belongs_to :user
  has_one :vote
  recursively_embeds_many

  validates :text, presence: true, length: { minimum: 3, maximum: 160 }
  validates :user, presence: true

  after_create :parse_text

  ### Actionable Methods ###

  def actor
    user
  end

  def scope
    'followers'
  end

  def metadata
    author_name = user.handle ? '@' + user.handle : user.full_name
    { author_type: user.class.name,
      author_id: user.id,
      author_name: author_name,
      data_type: 'text',
      data: text,
      created_at: created_at }
  end
end
