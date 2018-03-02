# Creates Tags and manages its HierarchyTree if necessary
class TaggableGenerator
  include ActiveModel::Validations

  attr_reader :taggable_class, :hierarchy_tree

  validate :valid_taggable

  validates :taggable_class, :hierarchy_tree, presence: true

  # Helper functions

  def to_embedded(target)
    if target.class.name == 'Array'
      target.map(&:embeddable_attributes)
    else
      target.present? ? target.embeddable_attributes : nil
    end
  end

  # Validation functions

  def valid_taggable
    return if @taggable_class.included_modules.include?(Taggable)
    errors.add('message', 'Target must include Taggable module.')
  end

  # Rating Generator Functions

  def initialize(taggable_class = nil)
    @taggable_class = taggable_class
    @hierarchy_tree = HierarchyTree.find_by(class_name: taggable_class.name)
    @hierarchy_tree ||= HierarchyTree.create(class_name: taggable_class.name)
  end

  def create_taggable(params)
    return unless valid?
    parent = @taggable_class.find_by(name: params[:parent])
    params[:parent] = parent
    taggable = @taggable_class.create(params)
    return unless taggable.valid?
    taggable.calculate_ancestry
    taggable.create_tag
    @hierarchy_tree.calculate_tree(@taggable_class)
  end

  def destroy_taggable(id)
    return unless valid?
    taggable = @taggable_class.find_by(id: id)
    return unless taggable.present?
    taggable.destroy
    @hierarchy_tree.calculate_tree(@taggable_class)
  end
end
