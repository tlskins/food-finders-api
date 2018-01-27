# Tag Model - A pointer to a taggable object
class Tag
  include Mongoid::Document
  include Mongoid::Timestamps

  # Unique identifier, per symbol, typed in a social entry
  field :handle, type: String
  # Tag name to be displayed
  field :name, type: String
  # The typed reserved symbol to indicate a taggable type
  field :symbol, type: String

  has_and_belongs_to_many :social_entries
  belongs_to :taggable, polymorphic: true

  def self.reserved_symbols
    ['#', '^', '@']
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

  scope :find_by_handle, lambda { |handle|
    where(symbol: handle[0], handle: handle[1..-1])
  }

  scope :find_by_handles, lambda { |*handles|
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
    whitelisted_attributes = %w[handle name symbol tag_id]
    # Delete all non whitelisted attributes
    embeddable_attrs.each_key do |key|
      embeddable_attrs.delete(key) if whitelisted_attributes.exclude?(key)
    end
  end

  def self.clean_handle(raw_handle)
    return if raw_handle.nil? || raw_handle.class.name != 'String'
    raw_handle.gsub(/[ ]/, '_').gsub(/['@#^*()`]/, '')
  end

  protected

  def write_taggable_data
    return if taggable.nil?
    # Need to standardize handle into a tag including:
    # Removing spaces, special chars except underscore
    self.handle = Tag.clean_handle(taggable.tagging_raw_handle)
    self.name = taggable.tagging_name
    self.symbol = taggable.tagging_symbol
  end
end
