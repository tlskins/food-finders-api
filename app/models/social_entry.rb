# Social Entry Model - a post or tweet
class SocialEntry
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include Actionable
  include Parseable

  field :text, type: String
  field :parent_social_entry_id, type: BSON::ObjectId
  field :set_scope, type: String
  field :embedded_reply_social_entries_count, type: Integer

  belongs_to :user
  has_one :food_rating

  embeds_many :embedded_reply_social_entries

  validates :text, presence: true, length: { minimum: 3, maximum: 160 }
  validates :user, presence: true

  def parent_social_entry
    return unless parent_social_entry_id.present?
    SocialEntry.find_by(id: parent_social_entry_id)
  end

  ### Actionable Methods ###

  def actor
    user
  end

  def scope
    set_scope || 'followers'
  end

  def metadata(include_parent = true)
    author_name = user.handle ? '@' + user.handle : user.full_name
    tag_attrs = tags.map(&:attributes)
    food_rating_attributes = food_rating && food_rating.embeddable_attributes
    hash = { id: id,
             author_type: user.class.name,
             author_id: user.id,
             author_name: author_name,
             data_type: 'text',
             data: text,
             replies_count: embedded_reply_social_entries_count,
             created_at: created_at,
             tags: tag_attrs,
             food_rating: food_rating_attributes }
    if include_parent && parent_social_entry.present?
      return hash.merge(
        parent_social_entry: parent_social_entry.metadata(false)
      )
    end
    hash
  end

  def subscriber_ids
    if parent_social_entry.present?
      [parent_social_entry.user_id]
    else
      []
    end
  end

  ### Rating Methods ###
  # TODO : Move to a concern

  attr_accessor(
    :rating_generator,
    :rateable, # food
    :rater, # user
    :ratee, # entity
    :rating_type, # rating type hashtag
    :rating_metrics, # rating metrics hashtag
  )

  @singular_rating_attributes = %w[rateable ratee rating_type]
  @multi_rating_attributes = %w[rating_metrics]
  @rating_class = FoodRating

  def self.singular_rating_attributes
    @singular_rating_attributes
  end

  def self.multi_rating_attributes
    @multi_rating_attributes
  end

  def self.rating_class
    @rating_class
  end

  def generate_food_rating
    return unless food_rating.nil? && tags.present? && user.present?
    @rating_generator = RatingGenerator.new(SocialEntry.rating_class, self, user)
    SocialEntry.singular_rating_attributes.each do |rating_attribute|
      attribute_class = SocialEntry.rating_class.relations[rating_attribute].class_name
      first_tag = tags.find_first_by_type(attribute_class)
      @rating_generator.send("#{rating_attribute}=", first_tag.taggable) if first_tag.present?
    end
    SocialEntry.multi_rating_attributes.each do |rating_attribute|
      attribute_class = SocialEntry.rating_class.relations[rating_attribute].class_name
      all_tags = tags.find_all_by_type(attribute_class)
      all_taggables = all_tags.map(&:taggable)
      @rating_generator.send("#{rating_attribute}=", all_taggables)
    end
    @rating_generator.create_rating if @rating_generator.valid?
  end
end
