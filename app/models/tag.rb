# Tag Model - A pointer to a taggable object
class Tag
  include Mongoid::Document
  include Mongoid::Timestamps

  field :handle, type: String
  field :name, type: String
  field :symbol, type: String
  field :embedded_taggable, type: Hash

  belongs_to :taggable, polymorphic: true

  before_validation :write_taggable_data

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

  scope :find_by_handles, lambda { |handles|
    handles = CGI.unescape(handles).split(',') if handles.class.name == 'String'
    or_array = handles.map { |h| { symbol: h[0], handle: h[1..-1] } }
    where(:$or => or_array)
  }

  scope :find_by_symbol, lambda { |symbol|
    parsed_symbol = symbol == '%23' ? '#' : symbol
    where(symbol: parsed_symbol)
  }

  scope :find_by_text, lambda { |text|
    text_regex = ::Regexp.new(text, ::Regexp::IGNORECASE)
    where(
      :$or => [
        { name: text_regex },
        { handle: text_regex },
        { 'embedded_taggable.description' => text_regex },
        { 'embedded_taggable.synonyms' => text_regex }
      ]
    )
  }

  scope :find_by_path, lambda { |path|
    tags.where(path: path)
  }

  # def taggable_type=(params)
  #   super(params)
  #   write_taggable_data
  # end

  def to_s
    symbol + handle
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
    puts 'write_taggable_data called!'
    return if taggable.nil?
    set(
      handle: Tag.clean_handle(taggable.tagging_raw_handle),
      name: taggable.tagging_name,
      symbol: taggable.tagging_symbol,
      embedded_taggable: taggable.taggable_attributes
    )
  end

  # def write_relational_tag_data
  #   return if taggable.nil?
  #   parent = taggable.parent
  #   parent_tag = (parent.tag && parent.tag.taggable_attributes)
  #   children = taggable.children || []
  #   children_tags = taggable.children.map(&:tag).map(&:taggable_attributes)
  #
  #   set(
  #     handle: Tag.clean_handle(taggable.tagging_raw_handle),
  #     name: taggable.tagging_name,
  #     symbol: taggable.tagging_symbol,
  #     parent: taggable.taggable_attributes
  #   )
  # end
end
