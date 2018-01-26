# Embedded Social Entry Model - meta data for social entry
class EmbeddedSocialEntry
  include Mongoid::Document
  include Mongoid::Timestamps

  field :text, type: String

  # has_and_belongs_to_many :tags, inverse_of: nil
  embeds_many :tags, as: :embeddable_tags, class_name: 'EmbeddedTag'
  embedded_in :embeddable_social_entry, polymorphic: true

  # TODO : Add back later / Include front end validation
  # validates :text, length: { maximum: 160 }

  # Parse text whenever text is updated
  def text=(params)
    super(params)
    parse_text
  end

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
