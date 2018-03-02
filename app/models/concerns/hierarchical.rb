# Provides a heiarchical framework
module Hierarchical
  extend ActiveSupport::Concern

  included do
    field :description, type: String
    field :synonyms, type: Array, default: []
    field :path, type: String
    field :depth, type: Integer

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

    validates :description, :path, :depth, presence: true

    index({ depth: 1 }, background: true)

    scope :roots, -> { where(depth: 0) }

    def self.calculate_roots
      all.each do |node|
        node.set_root if node.parent.nil?
      end
    end

    def self.calculate_all_ancestry(targets = nil)
      puts 'self.calculate_all_ancestry, targets=' + targets.inspect
      calculate_roots if targets.nil?
      targets ||= roots.entries
      targets.each do |target|
        target.calculate_ancestry
        calculate_all_ancestry(target.children) if target.children.present?
      end
    end
  end

  def calculate_ancestry
    return if parent.nil?
    update_attributes(
      path: parent.path + parent.name + '/',
      depth: parent.depth + 1
    )
  end

  def set_root
    update_attributes(
      path: '/',
      depth: 0
    )
  end
end
