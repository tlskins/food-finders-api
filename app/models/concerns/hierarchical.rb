# Provides a heiarchical framework
module Hierarchical
  extend ActiveSupport::Concern

  included do
    field :description, type: String
    field :synonyms, type: Array, default: []
    field :lineage, type: String, default: '/'
    field :generation, type: Integer, default: 0

    after_create :calculate_ancestry

    belongs_to(
      :parent,
      class_name: name,
      index: true,
      optional: true
    )
    has_many(
      :children,
      class_name: name,
      foreign_key: 'parent_id'
    )

    validates :description, :lineage, :generation, presence: true

    index({ generation: 1 }, background: true)

    scope :roots, -> { where(generation: 0) }
  end

  def calculate_ancestry
    return if parent.nil?
    update_attributes(
      lineage: parent.lineage + parent.name + '/',
      generation: parent.generation + 1
    )
  end
end
