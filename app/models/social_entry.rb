class SocialEntry
  include Mongoid::Document
  include Mongoid::Timestamps

  field :text, type: String

  belongs_to :user
  has_and_belongs_to_many :tags
  has_one :vote
  recursively_embeds_many

end
