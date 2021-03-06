# Provides all the functionality so that an object can be taggable
module Taggable
  extend ActiveSupport::Concern

  included do
    field :name, type: String

    has_one :tag, as: :taggable, dependent: :destroy

    validates(
      :name,
      presence: true,
      # uniqueness: true,
      # length: { minimum: 3, maximum: 20 }
      length: { minimum: 3 }
    )
  end

  def tagging_symbol
    raise 'tagging symbol not implemented!'
  end

  # Used to set a unique public tag identifier
  def tagging_raw_handle
    raise 'tagging raw handle not implemented!'
  end

  def handle
    db_value = super if defined? super
    return db_value if db_value.present?
    handlefy(tagging_raw_handle)
  end

  def to_s
    return unless tagging_symbol && tagging_raw_handle
    tagging_symbol + handle
  end

  # Used to set taggable symbol in tag
  def tagging_name
    name
  end

  def taggable_attributes
    { _id: _id,
      handle: handle,
      name: name,
      created_at: created_at }.merge(local_taggable_attributes)
  end

  def local_taggable_attributes
    {}
  end

  private

  def handlefy(raw_handle)
    return unless raw_handle.present?
    raw_handle.downcase.tr(' ', '-').gsub(/['@#^*()`]/, '')
  end
end
