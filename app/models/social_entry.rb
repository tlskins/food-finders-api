# Social Entry Model - a post or tweet
class SocialEntry
  include Mongoid::Document
  include Mongoid::Timestamps

  field :text, type: String

  belongs_to :user
  has_one :vote
  # has_and_belongs_to_many :tags
  embeds_many :tags, as: :embeddable_tags, class_name: 'EmbeddedTag'
  # TODO : build vote dynamically (not builT in embedded document)
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
end
