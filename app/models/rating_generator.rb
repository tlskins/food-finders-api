# Creates ratings and manages rating aggregates among all rating associations
class RatingGenerator
  include ActiveModel::Validations

  attr_accessor(
    :rating_class, # which class to create the rating in
    :social_entry,
    :rateable, # food
    :rater, # user
    :ratee, # entity
    :rating_type, # rating type hashtag
    :rating_metrics, # rating metrics hashtag
  )

  validate(
    :core_attributes_valid,
    :rating_class_valid,
    :rateable_data_type,
    :rater_data_type,
    :ratee_data_type,
    :rating_type_data_type,
    :rating_metrics_data_type
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

  def to_embedded(target)
    if target.class.name == 'Array'
      target.map(&:embeddable_attributes)
    else
      target.present? ? target.embeddable_attributes : nil
    end
  end

  # Validation functions

  def core_attributes_valid
    core_attributes = [@rateable, @rater, @ratee, @rating_type]
    return if core_attributes.all? { |atr| atr.present? && atr.valid? }
    errors.add('message', 'Not all core attributes present and valid.')
  end

  def rating_class_valid
    errors.add('rating_class', 'Must be defined.') if @rating_class.nil?
    return if @rating_class.included_modules.include?(Ratingable)
    errors.add('rating_class', 'Must be a class.')
  end

  def rateable_data_type
    return if @rateable.nil? || rateable?(@rateable)
    errors.add('rateable', 'Does not include Rateable module.')
  end

  def rater_data_type
    return if @rater.nil? || raterable?(@rater)
    errors.add('rater', 'Does not include Raterable module.')
  end

  def ratee_data_type
    return if @ratee.nil? || rateeable?(@ratee)
    errors.add('ratee', 'Does not include Rateeable module.')
  end

  def rating_type_data_type
    return if @rating_type.nil? || rating_typeable?(@rating_type)
    errors.add('rating_type', 'Does not include RatingTypeable module.')
  end

  def rating_metrics_data_type
    return if @rating_metrics.nil?
    return if @rating_metrics.all? { |metric| rating_metrizable?(metric) }
    errors.add('rating_metrics', 'Does not include RatingMetrizable module.')
  end

  # Rating Generator Functions

  def initialize(
    rating_class = nil,
    social_entry = nil,
    rater = nil,
    rateable = nil,
    ratee = nil,
    rating_type = nil,
    rating_metrics = []
  )
    @rating_class = rating_class
    @rateable = rateable
    @rater = rater
    @ratee = ratee
    @rating_type = rating_type
    @rating_metrics = rating_metrics
    @social_entry = social_entry
  end

  def initialize_testable
    @rating_class = FoodRating
    @social_entry = SocialEntry.last
    @rateable = Food.last
    @rater = User.first
    @ratee = Entity.last
    @rating_type = FoodRatingType.last
    @rating_metrics = [FoodRatingMetric.first, FoodRatingMetric.last]
  end

  # TODO : Make compatible with controller params

  def create_rating
    return unless valid?
    @rating_class.create(
      social_entry: @social_entry,
      rateable: @rateable,
      rater: @rater,
      ratee: @ratee,
      rating_type: @rating_type,
      rating_metrics: @rating_metrics
    )
    update_rating_aggregates
  end

  protected

  def update_rating_aggregates
    core_attributes = [@rateable, @rater, @ratee, @rating_type, @rating_metrics]
    core_attributes = core_attributes.flatten
    core_attributes.map(&:aggregate_ratings)
  end
end
