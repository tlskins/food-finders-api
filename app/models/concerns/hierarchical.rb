# Provides a heiarchical framework
module Hierarchical
  extend ActiveSupport::Concern
  include Taggable

  included do
    field :description, type: String
    field :synonyms, type: Array, default: []
    field :path, type: String
    field :depth, type: Integer

    belongs_to(
      :parent,
      class_name: name,
      index: true,
      counter_cache: true,
      optional: true
    )
    has_many(
      :children,
      class_name: name,
      foreign_key: 'parent_id'
    )

    validates :description, :path, :depth, presence: true

    before_validation :calculate_ancestry

    index({ depth: 1 }, background: true)

    scope :roots, -> { where(parent_id: nil) }

    def self.calculate_roots
      found_roots = all.entries.select { |node| node.parent.nil? }
      found_roots.each(&:calculate_ancestry)
    end

    def self.calculate_all_ancestry(targets = nil)
      calculate_roots if targets.nil?
      targets ||= roots.entries
      targets.each do |target|
        target.calculate_ancestry
        calculate_all_ancestry(target.children) if target.children.present?
      end
    end
  end

  def calculate_ancestry
    parent_path = parent ? parent.path + parent.name : ''
    parent_depth = parent ? parent.depth : 0
    set(
      path: parent_path + '/',
      depth: parent_depth + 1
    )
  end

  def tree
    HierarchyTree.find_by(class_name: self.class.name)
  end

  def roots
    self.class.roots.entries
  end

  def local_taggable_attributes
    { description: description,
      synonyms: synonyms,
      path: path,
      depth: depth,
      parent: parent_handle,
      parent_generation: parent_generation,
      children: children_handles }
  end

  protected

  def children_handles
    children.map(&:to_s)
  end

  private

  def parent_generation
    return unless parent.present?
    return root_handles if parent.depth == 1
    parent.parent.children_handles
  end

  def root_handles
    return unless roots.entries.present?
    roots.entries.map(&:to_s)
  end

  def parent_handle
    parent && parent.to_s
  end
end
