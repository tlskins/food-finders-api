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
    ) do
      def find_first_by_type(type)
        where('taggable_type' => type).entries.first
      end

      def find_all_by_type(type)
        where('taggable_type' => type).entries
      end
    end
  end

  TAG_DELIMITER = ' '.freeze
  TAG_KEYS = Tag.reserved_symbols.freeze

  attr_accessor :tag, :tag_start, :tag_end, :tag_located

  def reset_tag_parsing
    @tag = ''
    @tag_start = nil
    @tag_end = nil
    @tag_located = false
  end

  def parse_text
    # Remove existing tag data
    set(tags: [])
    return if text.empty?

    reset_tag_parsing
    text_arr = text.split('')
    text_arr.each_with_index.map do |char, index|
      if TAG_KEYS.include?(char) || @tag_located
        if char != TAG_DELIMITER
          @tag << char
          @tag_start = index if @tag_start.nil?
        end
        @tag_located = !(char == TAG_DELIMITER || index == text_arr.length - 1)
      end
      next unless !@tag_located && @tag.present?
      @tag_found = Tag.find_by_tag(@tag)
      if @tag_found.present?
        @tag_end = index == text_arr.length - 1 ? index + 1 : index
        attrs = @tag_found.embeddable_attributes
        attrs[:tag_start] = @tag_start
        attrs[:tag_end] = @tag_end
        tags.create(attrs)
      end
      reset_tag_parsing
    end
  end
end
