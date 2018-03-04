# Tag Model - tag meta data
class EmbeddedTag
  include Mongoid::Document
  include Mongoid::Timestamps

  field :handle, type: String
  field :name, type: String
  field :symbol, type: String
  field :taggable_type, type: String
  field :tag_start, type: Integer
  field :tag_end, type: Integer
  field :embedded_taggable, type: Hash

  belongs_to :tag

  embedded_in :embeddable_tag, polymorphic: true

  def to_s
    symbol + handle
  end
end
