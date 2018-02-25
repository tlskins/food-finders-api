# Creates ratings and manages rating aggregates among all rating associations
class RatingGenerator
  include ActiveModel::Validations

  attr_reader :ratable, :rater, :ratee, :rating_type, :rating_metrics

  validate :core_attributes_valid

  CORE_ATTRIBUTES = [@ratable, @rater, @ratee, @rating_type].freeze

  def initialize(
    ratable = nil,
    rater = nil,
    ratee = nil,
    rating_type = nil,
    rating_metrics = []
  )
    @ratable = ratable
    @rater = rater
    @ratee = ratee
    @rating_type = rating_type
    @rating_metrics = rating_metrics
  end

  def core_attributes_valid
    return if [@ratable, @rater, @ratee, @rating_type].all? do |atr|
      atr.present? && atr.valid?
    end
    errors.add('message', 'Not all core attributes present and valid')
  end

  def create_rating
    # TODO : update entity business with yelp business data
  end
end
