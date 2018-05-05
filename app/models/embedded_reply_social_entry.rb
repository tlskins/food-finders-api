# Social Entry Model - a post or tweet
class EmbeddedReplySocialEntry
  include Mongoid::Document
  include Mongoid::Timestamps
  include Parseable

  field :text, type: String
  field :user, type: Hash
  field :social_entry_id, type: BSON::ObjectId
  field :replies_count, type: Integer, default: 0

  embedded_in :social_entry, counter_cache: true

  def initialize(args)
    user = args[:user]
    if user.present? && user.class.name == 'User'
      args[:user] = user.embeddable_attributes
    end
    super
  end

  def social_entry
    return unless social_entry_id.present?
    SocialEntry.find_by(id: social_entry_id)
  end

  def author_name
    return unless user.present?
    author = User.find_by(id: user[:_id])
    author.full_handle
  end

  def update_social_entry
    root = social_entry
    set(
      text: root.text,
      replies_count: root.embedded_reply_social_entries_count
    )
  end

  def metadata
    { id: social_entry_id,
      author_type: 'User',
      author_id: user[:_id],
      author_name: author_name,
      data_type: 'text',
      data: text,
      created_at: created_at,
      tags: tags.map(&:attributes),
      replies_count: replies_count }
  end
end
