class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Taggable

  field :handle, type: String
  field :first_name, type: String
  field :last_name, type: String

  has_many :votes

  embeds_one :draft_social_entry, as: :embeddable_social_entry, class_name: 'EmbeddedSocialEntry', autobuild: true

  # TODO - name validitions on special chars, spaces
  validates :first_name, presence: true
  validates :last_name, presence: true

  # Used to set taggable symbol in tag
  def tagging_symbol
    "@"
  end

end
