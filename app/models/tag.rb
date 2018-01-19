class Tag
  include Mongoid::Document
  include Mongoid::Timestamps

  field :taggable_symbol, type: String
  field :taggable_name, type: String

  has_and_belongs_to_many :social_entries
  belongs_to :taggable, polymorphic: true

end
