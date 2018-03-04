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
      counter_cache: true,
      optional: true
    )
    has_many(
      :children,
      class_name: name,
      foreign_key: 'parent_id'
    )
    has_and_belongs_to_many(
      :siblings,
      class_name: name
    )

    validates :description, :path, :depth, presence: true

    index({ depth: 1 }, background: true)

    scope :roots, -> { where(depth: 0) }

    def self.calculate_roots
      all.entries.each do |node|
        node.set_root if node.parent.nil?
      end
    end

    def self.calculate_all_ancestry(targets = nil)
      # puts 'self.calculate_all_ancestry, targets=' + targets.inspect
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
    self.siblings = find_siblings
  end

  def tree
    HierarchyTree.find_by(class_name: self.class.name)
  end

  def find_siblings
    return self.class.roots.reject { |root| root.id == id } if parent.nil?
    parent.children.reject { |child| child.id == id }
  end

  def set_root
    update_attributes(
      path: '/',
      depth: 0
    )
    self.siblings = find_siblings
  end

  def orphan_taggable_attributes
    { _id: _id,
      name: name,
      description: description }
  end

  def taggable_attributes
    attrs = { _id: _id,
              name: name,
              description: description,
              synonyms: synonyms,
              created_at: created_at,
              parent: nil,
              children: [] }
    attrs[:parent] = parent.orphan_taggable_attributes if parent.present?
    attrs[:children] = children.map(&:orphan_taggable_attributes) if children.present?
    attrs
  end
end
