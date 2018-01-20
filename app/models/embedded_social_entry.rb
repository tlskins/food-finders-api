class EmbeddedSocialEntry
  include Mongoid::Document
  include Mongoid::Timestamps

  field :text, type: String

  has_and_belongs_to_many :tags, inverse_of: nil
  embedded_in :embeddable_social_entry, polymorphic: true

  validates :text, length: { maximum: 160 }

  def parse_text
    if text.present?
      handles = text.split(" ").select { |s| Tag.reserved_symbols.include?(s[0]) }
      self.tags = Tag.find_by_handles(*handles) if handles.present?
    end
  end
end
