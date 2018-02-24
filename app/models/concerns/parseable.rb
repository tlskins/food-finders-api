# Module for parsing tags in a text
module Parseable
  extend ActiveSupport::Concern

  included do
    # TODO : Add back later / Include front end validation
    # validates :text, length: { maximum: 160 }
    field :tag_indices, type: Array, default: []

    embeds_many(
      :tags,
      as: :embeddable_tags,
      class_name: 'EmbeddedTag'
    )
  end

  TAG_DELIMITER = ' '.freeze
  TAG_KEYS = Tag.reserved_symbols.freeze

  def identify_tags
    return if text.empty?
    # Find all words beginning with tag symbols
    text.split(' ').select { |s| Tag.reserved_symbols.include?(s[0]) }
  end

  def parse_text
    # Remove existing tag data
    tags.delete_all
    update_attributes(tag_indices: [])
    return if text.empty?

    tag = ''
    tag_index = []
    tag_located = false
    text.split('').each_with_index.map do |char, index|
      if char == TAG_DELIMITER && tag_located
        if tag.present?
          tag_found = Tag.find_by_tag(tag)
          if tag_found.present?
            tag_index[1] = index
            update_attributes(tag_indices: tag_indices << tag_index)
            tags.create(tag_found.embeddable_attributes)
          end
        end
        tag = ''
        tag_index = []
        tag_located = false
      elsif TAG_KEYS.include?(char) || tag_located
        tag << char
        tag_index[0] = index if tag_index[0].nil?
        tag_located = true
      end
    end
  end
end
