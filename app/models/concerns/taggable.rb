# Provides all the functionality so that an object can be taggable
module Taggable
  extend ActiveSupport::Concern

  included do
    field :name, type: String

    has_one :tag, as: :taggable, dependent: :destroy

    # TODO : Correct uniq validation for symbold + handle
    validates(
      :name,
      presence: true,
      uniqueness: true,
      length: { minimum: 3, maximum: 20 }
    )

    after_create :create_tag

    index({ name: 1 }, background: true, unique: true, drop_dups: true)
  end

  def tagging_symbol
    raise 'tagging_symbol not implemented!'
  end

  # Used to set a unique public tag identifier
  def tagging_raw_handle
    raise 'tagging_raw_handle not implemented!'
  end

  # Used to set taggable symbol in tag
  def tagging_name
    name
  end

  def handlefy(target)
    target.delete(' ')
  end
end
