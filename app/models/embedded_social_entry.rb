class EmbeddedSocialEntry
  include Mongoid::Document
  include Mongoid::Timestamps

  field :text, type: String

  # has_and_belongs_to_many :tags, inverse_of: nil
  embeds_many :tags, as: :embeddable_tags, class_name: 'EmbeddedTag'
  embedded_in :embeddable_social_entry, polymorphic: true

  # TODO - Add back later / Include front end validation
  # validates :text, length: { maximum: 160 }

  # Parse text whenever text is updated
  def text=(params)
    super(params)
    parse_text
  end

  def parse_text
    if text.present?
      handles = text.split(" ").select { |s| Tag.reserved_symbols.include?(s[0]) }
      if handles.present?
        # If tags are found create embedded tag docs for them
        self.tags.delete_all
        Tag.find_by_handles(*handles).map { |t| self.tags.create(t.embeddable_attributes) }
      end
    end
  end
end
