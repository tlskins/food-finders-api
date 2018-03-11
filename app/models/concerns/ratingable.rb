# Records user preferences
module Ratingable
  extend ActiveSupport::Concern

  included do
    # field :embedded_rateable, type: Hash
    # field :embedded_rater, type: Hash
    # field :embedded_ratee, type: Hash
    # field :embedded_rating_type, type: Hash
    # field :embedded_rating_metrics, type: Array

    validates :rateable, :rater, :ratee, :rating_type, presence: true
    # validate :associations_have_embeddable_attributes
  end

  # def associations_have_embeddable_attributes
  #   [rateable, rater, ratee, rating_type].select(&:present?).each do |assoc|
  #     if assoc.embeddable_attributes.nil?
  #       relation_name = assoc.__metadata.name
  #       errors.add(relation_name, 'Does not have embeddable attributes set.')
  #     end
  #   end
  # end
end
