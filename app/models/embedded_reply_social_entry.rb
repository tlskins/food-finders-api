# Social Entry Model - a post or tweet
class EmbeddedReplySocialEntry
  include Mongoid::Document
  include Mongoid::Timestamps
  include Parseable

  field :text, type: String
  field :user, type: Hash
  field :social_entry_id, type: BSON::ObjectId

  embedded_in :social_entry, counter_cache: true

  validates :text, presence: true, length: { minimum: 3, maximum: 160 }

  def initialize(args)
    user = args[:user]
    if user.present? && user.class.name == 'User'
      args[:user] = user.embeddable_attributes
    end
    super
  end

  def author_name
    return unless user.present?
    author = User.find_by(id: user[:_id])
    author.full_handle
  end

  def metadata
    { id: social_entry_id,
      author_type: 'User',
      author_id: user[:_id],
      author_name: author_name,
      data_type: 'text',
      data: text,
      created_at: created_at,
      tags: tags.map(&:attributes) }
  end
end
