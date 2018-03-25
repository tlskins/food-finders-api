# Creates Social Entries
class SocialEntryGenerator
  include ActiveModel::Validations

  attr_accessor(
    :rateable,
    :rateeable,
    :raterable,
    :rating_typeable,
    :rating_metrizables,
    :social_entry
  )

  # Helper functions

  def rateable?(target)
    target.class.included_modules.include?(Rateable)
  end

  def raterable?(target)
    target.class.included_modules.include?(Raterable)
  end

  def rateeable?(target)
    target.class.included_modules.include?(Rateeable)
  end

  def rating_typeable?(target)
    target.class.included_modules.include?(RatingTypeable)
  end

  def rating_metrizable?(target)
    target.class.included_modules.include?(RatingMetrizable)
  end

  # def categorize_tags
  #   return unless @social_entry
  #   @rating_metrizables ||= []
  #   @social_entry.tags.select do |tag|
  #     @rateable ||= tag if rateable?(tag)
  #     @rateeable ||= tag if rateeable?(tag)
  #     @raterable ||= tag if raterable?(tag)
  #     @rating_typeable ||= tag if rating_typeable?(tag)
  #     @rating_metrizables.push(tag) if rating_metrizable?(tag)
  #   end
  # end

  # def all_rating_components_present
  #   return false if @rateable.nil?
  #   return false if @rateeable.nil?
  #   return false if @raterable.nil?
  #   return false if @rating_typeable.nil?
  #   true
  # end

  # Generator functions

  # def new_social_entry(params)
  #   @social_entry = SocialEntry.new(params)
  #   return @social_entry unless @social_entry.valid?
  #   @social_entry.create_tags if create_tags
  #   @social_entry.generate_food_rating if @social_entry.tags.present?
  #   @social_entry.create_action
  # end

  def create_social_entry(params, create_tags = false)
    @social_entry = SocialEntry.new(params)
    return @social_entry unless @social_entry.valid?
    @social_entry.create_tags if create_tags
    @social_entry.save
    return @social_entry unless @social_entry.valid?
    @social_entry.parse_text
    @social_entry.generate_food_rating if @social_entry.tags.present?
    @social_entry.create_action
  end
end
