# Tag Model - A pointer to a taggable object
class Tag
  include Mongoid::Document
  include Mongoid::Timestamps

  field :handle, type: String
  field :name, type: String
  field :symbol, type: String
  field :embedded_taggable, type: Hash

  has_and_belongs_to_many :social_entries
  belongs_to :taggable, polymorphic: true

  def self.reserved_symbols
    ['#', '^', '@', '&']
  end

  # TODO : Fix valid tag format regex
  # , format: { with: /[ '@#^*()`]/, message: "Invalid Tag handle format" }

  validates(
    :handle,
    presence: true,
    length: { minimum: 3, maximum: 20 },
    uniqueness: { scope: :symbol, message: 'Tag already exists' }
  )
  validates(
    :symbol,
    presence: true,
    inclusion: {
      in: Tag.reserved_symbols,
      message: 'Not a valid taggable symbol'
    }
  )

  index({ symbol: 1, name: 1 }, background: true)
  index({ symbol: 1, handle: 1 }, unique: true, background: true)

  def self.find_by_tag(handle)
    find_by(symbol: handle[0], handle: handle[1..-1])
  end

  scope :find_by_tags, lambda { |*handles|
    or_array = handles.map { |h| { symbol: h[0], handle: h[1..-1] } }
    where(:$or => or_array)
  }

  def taggable_type=(params)
    super(params)
    write_taggable_data
  end

  def embeddable_attributes
    embeddable_attrs = attributes
    # Transpose id to tag_id for belongs to tag association
    embeddable_attrs['tag_id'] = embeddable_attrs['_id']
    whitelisted_attrs = %w[handle name symbol tag_id taggable_type embedded_taggable]
    embeddable_attrs.each_key do |key|
      embeddable_attrs.delete(key) if whitelisted_attrs.exclude?(key)
    end
  end

  def self.clean_handle(raw_handle)
    return if raw_handle.nil? || raw_handle.class.name != 'String'
    raw_handle.gsub(/[ ]/, '_').gsub(/['@#^*()`]/, '')
  end

  def write_taggable_data
    return if taggable.nil?
    self.handle = Tag.clean_handle(taggable.tagging_raw_handle)
    self.name = taggable.tagging_name
    self.symbol = taggable.tagging_symbol
    return unless taggable.taggable_attributes.present?
    self.embedded_taggable = taggable.taggable_attributes
  end
end
