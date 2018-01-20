class SocialEntry
  include Mongoid::Document
  include Mongoid::Timestamps

  field :text, type: String

  belongs_to :user
  has_one :vote
  # has_and_belongs_to_many :tags
  embeds_many :tags, as: :embeddable_tags, class_name: 'EmbeddedTag'
  # TODO - build vote dynamically (not builT in embedded document)
  recursively_embeds_many

  validates :text, presence: true, length: { minimum: 3, maximum: 160 }
  validates :user, presence: true

  def parse_text
    if text.present?
      handles = text.split(" ").select { |s| Tag.reserved_symbols.include?(s[0]) }
      if handles.present?
        # If tags are found create embedded tag docs for them
        Tag.find_by_handles(*handles).map { |t| self.tags.create(t.embeddable_attributes) }
      end
    end
  end
end
