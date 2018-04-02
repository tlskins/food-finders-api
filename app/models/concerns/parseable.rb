# Module for parsing tags in a text
module Parseable
  extend ActiveSupport::Concern

  included do
    # TODO : Add back later / Include front end validation
    # validates :text, length: { maximum: 160 }

    field :creatable_tags, type: Array, default: []
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

  # TODO: Refactor and support tags that end with a punctuation
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

  def create_tags
    return if creatable_tags.empty?
    # Create Entity Tags
    entity_tags = creatable_tags.select { |t| t[:taggable_type] == 'Entity' }
    entity_tags.each_with_index do |tag, index|
      # Check if tag already exists
      db_entity = Entity.find_by(yelp_business_id: tag[:handle])
      if db_entity.present?
        delete_creatable_tag_at(index)
        next
      end
      # Verify id from yelp and get latest business data
      yelp_entity = Entity.yelp_businesses(tag[:handle])
      next if yelp_entity[:id].nil?
      new_entity = Entity.create_from_yelp(yelp_entity)
      return new_entity if new_entity.invalid?
      new_entity.reload
      new_entity.create_tag
      delete_creatable_tag_at(index)
    end
    # Create Food Tags
    food_tags = creatable_tags.select { |t| t[:taggable_type] == 'Food' }
    food_tags.each_with_index do |tag, index|
      # Check if tag already exists
      db_entity = Tag.find_by(taggable_type: 'Food', handle: tag[:handle])
      if db_entity.present?
        delete_creatable_tag_at(index)
        next
      end
      new_food = Food.new(tag[:taggable_object])
      return new_food if new_food.invalid?
      new_food.create_tag
      delete_creatable_tag_at(index)
    end
  end

  def delete_creatable_tag_at(index)
    creatable_tags.delete_at(index)
    set(creatable_tags: creatable_tags)
  end

  def validate_creatable_tags
    return if creatable_tags.nil? || creatable_tags.empty?
    unique_tags = creatable_tags.uniq { |t| t[:symbol] + t[:handle] }
    valid_tags = unique_tags.select do |tag|
      match_text = '\\' + tag[:symbol] + tag[:handle]
      Regexp.new(match_text).match(text)
    end
    set(creatable_tags: valid_tags)
  end
end
