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
end
