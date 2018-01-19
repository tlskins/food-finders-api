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
    %w(# ^ @)
  end

  validates :handle,
    presence: true,
    length: { minimum: 3, maximum: 20 },
    uniqueness: { scope: :symbol, message: "Tag already exists" }
    # , format: { with: /[ '@#^*()`]/, message: "Invalid Tag handle format" }
  validates :symbol,
    presence: true,
    inclusion: { in: Tag.reserved_symbols,
    message: "%{value} is not a valid taggable symbol" }

  index({ symbol: 1, name: 1 }, { background: true })
  index({ symbol: 1, handle: 1 }, { unique: true, background: true })

  def taggable_type=(params)
    super(params)
    write_taggable_data
  end

  scope :find_by_handle, ->(handle){ where(symbol: handle[0], handle: handle[1..-1]) }

  scope :find_by_handles, ->(*handles){
    or_array = handles.map { |h| { symbol: h[0], handle: h[1..-1] } }
    where("$or": or_array )
  }

  protected

    def write_taggable_data
      if taggable.present?
        # Need to standardize handle into a tag including: Removing spaces, special chars except underscore
        self.handle = Tag.clean_handle(taggable.tagging_raw_handle)
        self.name = taggable.tagging_name
        self.symbol = taggable.tagging_symbol
      end
    end

    def self.clean_handle(raw_handle)
      raw_handle.gsub(/[ ]/,"_").gsub(/['@#^*()`]/,"") if raw_handle.present? && raw_handle.class.name == "String"
    end
end
