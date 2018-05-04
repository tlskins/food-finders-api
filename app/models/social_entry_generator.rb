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

  def create_social_entry(params, parent_social_entry_id, create_tags = false)
    if parent_social_entry_id
      create_reply_social_entry(params, parent_social_entry_id, create_tags)
    else
      create_root_social_entry(params, create_tags)
    end
  end

  def create_root_social_entry(params, create_tags = false)
    @social_entry = SocialEntry.create(params)
    return @social_entry unless @social_entry.valid?
    @social_entry.parse_text
    if create_tags
      @social_entry.create_tags
      @social_entry.parse_text
    end
    return @social_entry unless @social_entry.valid?
    @social_entry.generate_food_rating if @social_entry.tags.present?
    @social_entry.create_action
    @social_entry
  end

  def create_reply_social_entry(params, parent_social_entry_id, create_tags = false)
    @parent = SocialEntry.find(BSON::ObjectId(parent_social_entry_id))
    # TODO : move root params to social entry model
    root_params = params.merge(
      parent_social_entry_id: BSON::ObjectId(parent_social_entry_id),
      set_scope: 'subscribers'
    )
    @root_entry = SocialEntry.create(root_params)
    return @root_entry unless @root_entry.valid?
    # TODO : move embed params to social entry model
    embed_params = params.merge(social_entry_id: @root_entry.id)
    @embed_entry = @parent.embedded_reply_social_entries.create(embed_params)
    @root_entry.parse_text
    @embed_entry.parse_text
    if create_tags
      @root_entry.create_tags
      @embed_entry.create_tags
      @root_entry.parse_text
      @embed_entry.parse_text
    end
    @parent.update_action
    @root_entry.create_action
    @root_entry
  end
end
