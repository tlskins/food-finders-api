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

  TAG_KEYS = Tag.reserved_symbols.freeze

  def parse_text
    # Remove existing tag data
    set(tags: [])

    valid_tagged_words(text).each do |valid_tag|
      attrs = valid_tag[:tag].embeddable_attributes
      attrs[:tag_start] = valid_tag[:start]
      attrs[:tag_end] = valid_tag[:end]
      tags.create(attrs)
    end
  end

  def create_tags
    return if creatable_tags.empty?
    create_tags_type(creatable_entity_tags) do |tag|
      create_entity_tag(tag)
    end
    create_tags_type(creatable_food_tags) do |tag|
      create_food_tag(tag)
    end
  end

  def delete_creatable_tag_at(index)
    creatable_tags.delete_at(index)
    set(creatable_tags: creatable_tags)
  end

  def validate_creatable_tags
    return if creatable_tags.nil? || creatable_tags.empty?
    valid_tags = contained_creatable_tags(unique_creatable_tags(creatable_tags))
    set(creatable_tags: valid_tags)
  end

  private

  # Tags

  def word_indices_array(text)
    enum = text.enum_for(:scan, /[^ \.,]+/)
    enum.map do |_|
      word_start = Regexp.last_match.begin(0)
      word_length = Regexp.last_match(0).length
      [word_start, word_start + word_length]
    end
  end

  def words(text)
    indices_array = word_indices_array(text)
    indices_array.map do |array|
      { text: text.slice(array[0], array[1] - array[0]),
        start: array[0],
        end: array[1] }
    end
  end

  def tagged_words(text)
    words(text).select { |w| TAG_KEYS.include?(w[:text][0]) }
  end

  def valid_tagged_words(text)
    tagged_words(text).map do |word_hash|
      word_hash[:tag] = Tag.find_by_tag(word_hash[:text])
      word_hash[:tag] && word_hash
    end.select(&:present?)
  end

  # Creatable Tags

  def unique_creatable_tags(creatable_tags)
    creatable_tags.uniq { |t| t[:symbol] + t[:handle] }
  end

  def contained_creatable_tags(creatable_tags)
    creatable_tags.select do |tag|
      match_text = '\\' + tag[:symbol] + tag[:handle]
      Regexp.new(match_text).match(text)
    end
  end

  def creatable_entity_tags(creatable_tags)
    creatable_tags.select { |t| t[:taggable_type] == 'Entity' }
  end

  def creatable_food_tags(creatable_tags)
    creatable_tags.select { |t| t[:taggable_type] == 'Food' }
  end

  def create_entity_tag(tag)
    yelp_entity = Entity.yelp_businesses(tag[:handle])
    return if yelp_entity['id'].nil?
    new_entity = Entity.create_from_yelp(yelp_entity)
    return if new_entity.invalid?
    new_entity.create_tag
  end

  def create_food_tag(tag)
    new_food = Food.new(tag[:taggable_object])
    return if new_food.invalid?
    new_food.create_tag
  end

  def entity_tag_exists(entity_handle)
    Tag.find_by(taggable_type: 'Entity', handle: entity_handle)
  end

  def food_tag_exists(food_handle)
    Tag.find_by(taggable_type: 'Food', handle: food_handle)
  end

  def create_tags_type(creatable_tags)
    creatable_tags.each_with_index do |tag, index|
      if entity_tag_exists(tag[:handle]) || yield(tag)
        delete_creatable_tag_at(index)
      end
    end
  end
end
