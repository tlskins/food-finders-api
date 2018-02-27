# Creates ratings and manages rating aggregates among all rating associations
class RatingGenerator
  include ActiveModel::Validations

  attr_reader(
    :social_entry,
    :rateable, # food
    :rater, # user
    :ratee, # entity
    :rating_type, # rating type hashtag
    :rating_metrics, # rating metrics hashtag
  )

  validate(
    :core_attributes_valid,
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

  # TODO : Need to find a way to make this polymorphic
  def rating_metrizable?(target)
    target.class <= RatingMetricHashtag
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
    return if [@rateable, @rater, @ratee, @rating_type].all? do |attribute|
      attribute.present? && attribute.valid?
    end
    errors.add('message', 'Not all core attributes present and valid')
  end

  def rateable_data_type
    return if @rateable.nil?
    errors.add('rateable', 'Only Foods are rateable.') if @rateable.class.name != 'Food'
    errors.add('rateable', 'Does not include Rateable module.') unless rateable?(@rateable)
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
    errors.add('rating_metrics', 'Must all inherit from RatingMetricHashtag.')
  end

  # Rating Generator Functions

  def initialize(
    rateable = nil,
    rater = nil,
    ratee = nil,
    rating_type = nil,
    rating_metrics = [],
    social_entry = nil
  )
    @rateable = rateable
    @rater = rater
    @ratee = ratee
    @rating_type = rating_type
    @rating_metrics = rating_metrics
    @social_entry = social_entry
  end

  def initialize_testable
    @social_entry = SocialEntry.last
    @rateable = Food.last
    @rater = User.first
    @ratee = Entity.last
    @rating_type = RatingTypeHashtag.last
    @rating_metrics = [RatingMetricHashtag.first, RatingMetricHashtag.last]
  end

  def create_rating
    return unless valid?
    Rating.create(
      social_entry: @social_entry,
      rateable: @rateable,
      rater: @rater,
      ratee: @ratee,
      rating_typeable: @rating_type,
      rating_metric_hashtags: @rating_metrics,
      embedded_rateable: to_embedded(@rateable),
      embedded_rater: to_embedded(@rater),
      embedded_ratee: to_embedded(@ratee),
      embedded_rating_typeable: to_embedded(@rating_type),
      embedded_rating_metric_hashtags: to_embedded(@rating_metrics)
    )
  end

  def update_rating_aggregates
    # def calculate_vote_totals
    #   vote_totals = votes.collection.aggregate(
    #     [{ :$group =>
    #         { '_id' =>
    #           { entity_name: '$entity_name', food_name: '$food_name' },
    #           'count' => { :$sum => 1 } } }]
    #   ).entries
    #   update_attribute(:vote_totals, vote_totals)
    # end
    #
    # TODO : Add index to embedded.names
    # TODO : Just aggregate by most granular level then re-aggregate as needed on front end
    Rating.collection.aggregate(
      [{ :$group =>
        { '_id' =>
          { entity_name: '$embedded_ratee.name' },
          'count' => { :$sum => 1 } } }]
    ).entries
  end
end
