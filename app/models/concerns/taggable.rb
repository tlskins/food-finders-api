module Taggable
  extend ActiveSupport::Concern

  included do
    field :name, type: String

    has_one :tag, as: :taggable

    validates :name, presence: true, uniqueness: true, length: { minimum: 3, maximum: 20 }

    index({ name: 1 }, { background: true, unique: true, drop_dups: true })
  end

  def tagging_symbol
    "#"
  end

  # Used to set a unique public tag identifier
  def tagging_raw_handle
    # If unique handle is already chosen use that
    return handle if handle.present?

    name
  end

  # Used to set taggable symbol in tag
  def tagging_name
    name
  end

end
