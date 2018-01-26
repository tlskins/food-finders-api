# Tag Model - tag meta data
class EmbeddedTag
  include Mongoid::Document
  include Mongoid::Timestamps

  field :handle, type: String
  field :name, type: String
  field :symbol, type: String
  belongs_to :tag

  embedded_in :embeddable_tag, polymorphic: true

  def to_s
    symbol + handle
  end
end
