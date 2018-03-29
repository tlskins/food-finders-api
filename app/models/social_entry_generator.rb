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

  # Generator functions

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
