# Social Entry Model - a post or tweet
class SocialEntry
  include Mongoid::Document
  include Mongoid::Timestamps
  include Actionable

  field :text, type: String

  belongs_to :user
  has_one :vote
  embeds_many :tags, as: :embeddable_tags, class_name: 'EmbeddedTag'
  recursively_embeds_many

  validates :text, presence: true, length: { minimum: 3, maximum: 160 }
  validates :user, presence: true

  def identify_handles
    return if text.empty?
    # Find all words beginning with handle symbols
    text.split(' ').select { |s| Tag.reserved_symbols.include?(s[0]) }
  end

  def parse_text
    return if text.empty?

    handles = identify_handles
    return if handles.empty?

    # Remove existing tags
    tags.delete_all
    # Create embedded tag docs for them
    Tag.find_by_handles(*handles).map do |t|
      tags.create(t.embeddable_attributes)
    end
  end

  ### Actionable Methods ###

  def actor
    user
  end

  def scope
    'followers'
  end

  def metadata
    { author_type: user.class.name,
      author_id: user.id,
      data_type: 'text',
      data: text,
      created_at: created_at }
  end
end
