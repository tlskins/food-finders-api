# Hash representation of a hiearchy relationship
class HierarchyTree
  include Mongoid::Document
  include Mongoid::Timestamps::Created

  field :class_name, type: String
  field :symbol, type: String
  field :tree, type: Hash, default: {}

  index({ class_name: 1 }, background: true, unique: true, drop_dups: true)

  def calculate_tree(target_class)
    return false unless target_class.included_modules.include?(Hierarchical)
    new_tree = {}
    tagging_symbol = nil
    target_class.roots.each do |root|
      tagging_symbol ||= root.tagging_symbol
      map_children(root, new_tree)
    end
    update_attributes(
      class_name: target_class.name,
      tree: new_tree
    )
  end

  def map_children(target, target_hash)
    target_hash[target.name] = target.embeddable_attributes
    target_hash[target.name][:handle] = target.tag.handle if target.tag.present?
    target.children.each do |child|
      target_hash[target.name][:children] ||= {}
      map_children(child, target_hash[target.name][:children])
    end
  end
end
