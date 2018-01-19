class SocialEntry
  include Mongoid::Document
  include Mongoid::Timestamps

  field :text, type: String

  belongs_to :user
  has_and_belongs_to_many :tags
  has_one :vote
  recursively_embeds_many

  validates :text, presence: true, length: { minimum: 3, maximum: 160 }
  validates :user, presence: true

  def parse_text
    if text.present?
      handles = text.split(" ").select { |s| Tag.reserved_symbols.include?(s[0]) }
      self.tags = Tag.find_by_handles(*handles)
    end
  end
end
