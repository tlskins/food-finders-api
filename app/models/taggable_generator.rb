# Creates Tags and manages its HierarchyTree if necessary
class TaggableGenerator
  include ActiveModel::Validations

  attr_reader :taggable, :taggable_class, :hierarchy_tree

  validates :taggable_class, :hierarchy_tree, presence: true
  validate :valid_taggable_class

  # Helper functions

  def to_embedded(target)
    if target.class.name == 'Array'
      target.map(&:embeddable_attributes)
    else
      target.present? ? target.embeddable_attributes : nil
    end
  end

  # Validation functions

  def valid_taggable_class
    return if @taggable_class.included_modules.include?(Taggable)
    errors.add('message', 'Target must include Taggable module.')
  end

  # Rating Generator Functions

  def initialize(taggable_class)
    @taggable_class = taggable_class
    @hierarchy_tree = HierarchyTree.find_by(class_name: taggable_class.name)
    @hierarchy_tree ||= HierarchyTree.create(class_name: taggable_class.name)
  end

  def create_taggable(params)
    return unless valid?
    parent = @taggable_class.find_by(name: params[:parent])
    params[:parent] = parent
    @taggable = @taggable_class.create(params)
    return @taggable unless @taggable.valid?
    @taggable.calculate_ancestry
    @taggable.create_tag
    @hierarchy_tree.calculate_tree(@taggable_class)
    @taggable
  end

  def find_taggable(param)
    return unless @taggable_class.present?
    @taggable = @taggable_class.find_by(id: param)
    @taggable ||= @taggable_class.find_by(name: param)
    @taggable
  end

  def update_all_taggables
    @taggable_class.all.each do |taggable|
      @taggable = taggable
      update_taggable(nil, false)
    end
    @hierarchy_tree.calculate_tree(@taggable_class)
  end

  def update_taggable(params = nil, build_tree = true)
    return unless valid? && @taggable.present?
    @taggable.update(params) if params.present?
    return @taggable unless @taggable.valid?
    @taggable.calculate_ancestry
    @taggable.save
    if @taggable.tag.present?
      @taggable.tag.write_taggable_data
    else
      @taggable.create_tag
    end
    @hierarchy_tree.calculate_tree(@taggable_class) if build_tree
  end

  def destroy_taggable
    return unless valid? && @taggable.present?
    @taggable.destroy
    @hierarchy_tree.calculate_tree(@taggable_class)
  end
end
