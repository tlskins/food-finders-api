# Creates Tags and manages its HierarchyTree if necessary
class TaggableGenerator
  include ActiveModel::Validations

  attr_reader :taggable, :parent_taggable, :taggable_class, :hierarchy_tree

  validate :valid_taggable_class

  # Validation functions

  def valid_taggable_class
    return if @taggable_class || @taggable_class.included_modules.include?(Taggable)
    errors.add('message', 'Target must include Taggable module.')
  end

  # Rating Generator Functions

  def initialize(taggable_class)
    @taggable_class = taggable_class
    @hierarchy_tree = HierarchyTree.find_by(class_name: taggable_class.name)
  end

  def find_taggable(param)
    return unless @taggable_class.present?
    @taggable = @taggable_class.find_by(id: param)
    @taggable ||= @taggable_class.find_by(name: param)
    @parent_taggable = @taggable.parent if @taggable.parent
    @taggable
  end

  def create_taggable(params)
    return unless valid?
    @taggable = @taggable_class.new(params)
    @taggable.save
    return @taggable unless @taggable.valid?
    @parent_taggable = @taggable.parent
    update_tag
    update_parent_tag
    update_hierarchy_tree
    @taggable
  end

  def update_all_taggables(recreate_tags = false)
    @taggable_class.all.each do |taggable|
      @taggable = taggable
      update_taggable(nil, false, recreate_tags)
    end
    update_hierarchy_tree
  end

  def update_taggable(params = nil, build_tree = true, recreate_tags = false)
    return unless valid? && @taggable.present?
    @taggable.update(params) if params.present?
    return @taggable unless @taggable.valid?
    update_tag(recreate_tags)
    update_hierarchy_tree if build_tree
    @taggable
  end

  def destroy_taggable
    return unless valid? && @taggable.present?
    @taggable.destroy
    update_parent_tag
    update_hierarchy_tree
  end

  private

  def update_parent_tag
    return if @parent_taggable.nil? || @parent_taggable.tag.nil?
    @parent_taggable.tag.write_taggable_data
  end

  def update_tag(recreate = false)
    tag = @taggable.tag
    if tag.present?
      recreate ? recreate_tag(@taggable) : tag.write_taggable_data
    else
      @taggable.create_tag
    end
  end

  def recreate_tag
    tag = @taggable.tag
    tag.destroy if tag.present?
    @taggable.create_tag
  end

  def update_hierarchy_tree
    return if @hierarchy_tree.nil?
    @hierarchy_tree.calculate_tree(@taggable_class)
  end
end
