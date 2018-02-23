# Module for parsing tags in a text
module Parseable
  extend ActiveSupport::Concern

  included do
    # TODO : Add back later / Include front end validation
    # validates :text, length: { maximum: 160 }
    embeds_many(
      :tags,
      as: :embeddable_tags,
      class_name: 'EmbeddedTag'
    )
  end

  def identify_handles
    return if text.empty?
    # Find all words beginning with handle symbols
    text.split(' ').select { |s| Tag.reserved_symbols.include?(s[0]) }
  end

  def parse_text
    # Remove existing tags
    tags.delete_all
    return if text.empty?

    handles = identify_handles
    return if handles.empty?

    # Create embedded tag docs for them
    Tag.find_by_handles(*handles).map do |t|
      tags.create(t.embeddable_attributes)
    end
  end
end
