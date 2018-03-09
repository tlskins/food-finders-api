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
    # has_and_belongs_to_many(
    #   :siblings,
    #   class_name: name
    # )

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
    # self.siblings = find_siblings
  end

  def tree
    HierarchyTree.find_by(class_name: self.class.name)
  end

  # def find_siblings
  #   return self.class.roots.reject { |root| root.id == id } if parent.nil?
  #   parent.children.reject { |child| child.id == id }
  # end

  def set_root
    update_attributes(
      path: '/',
      depth: 0
    )
    # self.siblings = find_siblings
  end

  def child_taggable_attributes
    if tag.present?
      tag_handle = tag.handle
      tag_symbol = tag.symbol
      taggable_type = tag.taggable_type
    end
    { _id: _id,
      name: name,
      description: description,
      tag_handle: tag_handle,
      tag_symbol: tag_symbol,
      taggable_type: taggable_type }
  end

  def parent_taggable_attributes
    if tag.present?
      tag_handle = tag.handle
      tag_symbol = tag.symbol
      taggable_type = tag.taggable_type
    end
    # siblings = parent.present? ?
    # parent.children.reject { |c| c.id == id }
    # :
    # self.class.roots.reject { |r| r.id == id }
    siblings = if parent.present?
                 parent.children.reject { |c| c.id == id }
               else
                 self.class.roots.reject { |r| r.id == id }
               end
    siblings = siblings.map(&:tag).map(&:to_s)
    { _id: _id,
      name: name,
      description: description,
      tag_handle: tag_handle,
      tag_symbol: tag_symbol,
      taggable_type: taggable_type,
      siblings: siblings }
  end

  def taggable_attributes
    attrs = { _id: _id,
              name: name,
              description: description,
              synonyms: synonyms,
              created_at: created_at,
              parent: nil,
              children: [] }
    attrs[:parent] = parent.parent_taggable_attributes if parent.present?
    attrs[:children] = children.map(&:child_taggable_attributes) if children.present?
    attrs
  end
end
