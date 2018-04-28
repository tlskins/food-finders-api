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

  # def create_tags
  #   return if creatable_tags.empty?
  #   create_entity_tags(creatable_tags)
  #   create_food_tags(creatable_tags)
  # end

  def create_tags
    Rails.logger.debug 'begin create_tags, creatable_tags =' + creatable_tags.inspect
    to_delete_tags = []
    creatable_tags.each do |tag|
      Rails.logger.debug 'tag =' + tag.inspect
      type = tag[:taggable_type]
      if Tag.find_by(taggable_type: type, handle: tag[:handle])
        Rails.logger.debug 'tag found'
        to_delete_tags.push(tag)
      elsif type == 'Food'
        Rails.logger.debug 'food tag found'
        create_food_tag(tag)
        to_delete_tags.push(tag)
      elsif type == 'Entity'
        Rails.logger.debug 'entity tag found'
        create_entity_tag(tag)
        to_delete_tags.push(tag)
      end
    end
    delete_creatable_tags(to_delete_tags)
  end

  def delete_creatable_tags(tags)
    tags.each { |t| delete_creatable_tag(t) }
  end

  def delete_creatable_tag(tag)
    Rails.logger.debug 'begin delete_creatable_tag, tag=' + tag.inspect
    creatable_tags.delete(tag)
    set(creatable_tags: creatable_tags)
    Rails.logger.debug 'creatable_tags after delete=' + creatable_tags.inspect
  end

  def validate_creatable_tags
    return if creatable_tags.nil? || creatable_tags.empty?
    valid_tags = contained_creatable_tags(unique_creatable_tags(creatable_tags))
    set(creatable_tags: valid_tags)
  end

  # private

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
      if word_hash[:tag]
        word_hash
      elsif word_hash[:text][0] == '@'
        # below logic belongs in creatable tags model
        handle = word_hash[:text][1..-1]
        unless creatable_tags.find { |t| t[:handle] == handle }
          creatable_tags.push(
            taggable_type: 'Entity',
            symbol: '@',
            handle: handle
          )
          # set(creatable_tags: creatable_tags)
        end
      end
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

  def create_entity_tag(tag)
    Rails.logger.debug 'begin create_entity_tag, tag=' + tag.inspect
    yelp_entity = Entity.yelp_businesses(tag[:handle])
    Rails.logger.debug 'create_entity_tag, yelp_entity=' + yelp_entity.inspect
    return if yelp_entity['alias'].nil?
    new_entity = Entity.create_from_yelp(yelp_entity)
    Rails.logger.debug 'create_entity_tag, new_entity=' + new_entity.inspect
    return if new_entity.invalid?
    new_entity.create_tag
    Rails.logger.debug 'post create entity tag'
  end

  def create_food_tag(tag)
    Rails.logger.debug 'begin create_food_tag, tag=' + tag.inspect
    new_food = Food.new(tag[:taggable_object])
    Rails.logger.debug 'begin create_food_tag, new_food=' + new_food.inspect
    return if new_food.invalid?
    new_food.create_tag
    Rails.logger.debug 'post create food tag'
  end

  # def creatable_entity_tags(creatable_tags)
  #   creatable_tags.select { |t| t[:taggable_type] == 'Entity' }
  # end
  #
  # def creatable_food_tags(creatable_tags)
  #   creatable_tags.select { |t| t[:taggable_type] == 'Food' }
  # end

  # def entity_tag_exists(entity_handle)
  #   Tag.find_by(taggable_type: 'Entity', handle: entity_handle)
  # end
  #
  # def food_tag_exists(food_handle)
  #   Tag.find_by(taggable_type: 'Food', handle: food_handle)
  # end

  # def create_entity_tags(creatable_tags)
  #   creatable_entity_tags(creatable_tags).each do |tag|
  #     if entity_tag_exists(tag[:handle]) || create_entity_tag(tag)
  #       delete_creatable_tag(tag)
  #     end
  #   end
  # end
  #
  # def create_food_tags(creatable_tags)
  #   creatable_food_tags(creatable_tags).each do |tag|
  #     if food_tag_exists(tag[:handle]) || create_food_tag(tag)
  #       delete_creatable_tag(tag)
  #     end
  #   end
  # end
end
