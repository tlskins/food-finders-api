# Creates Tags and manages its HierarchyTree if necessary
class TaggableGenerator
  include ActiveModel::Validations

  attr_reader :taggable, :parent_taggable, :taggable_class, :hierarchy_tree

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
    @taggable = @taggable_class.new(params)
    @taggable.calculate_ancestry
    @taggable.save
    @parent_taggable = @taggable.parent
    return @taggable unless @taggable.valid?
    @taggable.create_tag
    update_parent_tag
    @hierarchy_tree.calculate_tree(@taggable_class)
    @taggable
  end

  def find_taggable(param)
    return unless @taggable_class.present?
    @taggable = @taggable_class.find_by(id: param)
    @taggable ||= @taggable_class.find_by(name: param)
    @parent_taggable = @taggable.parent if @taggable.parent
    @taggable
  end

  def update_all_taggables(recreate_tags = false)
    @taggable_class.all.each do |taggable|
      @taggable = taggable
      update_taggable(nil, false, recreate_tags)
    end
    @hierarchy_tree.calculate_tree(@taggable_class)
  end

  def update_taggable(params = nil, build_tree = true, recreate_tags = false)
    return unless valid? && @taggable.present?
    @taggable.update(params) if params.present?
    return @taggable unless @taggable.valid?

    @taggable.calculate_ancestry
    @taggable.save
    # update tag
    if @taggable.tag.present?
      if recreate_tags
        @taggable.tag.destroy
        @taggable.create_tag
      else
        @taggable.tag.write_taggable_data
      end
    else
      @taggable.create_tag
    end
    # update parent tag
    if params.keys.include?('parent_id')
      @parent_taggable ||= @taggable_class.find_by(id: params['parent_id'])
      update_parent_tag
    end
    # update tree
    @hierarchy_tree.calculate_tree(@taggable_class) if build_tree
    @taggable
  end

  def destroy_taggable
    return unless valid? && @taggable.present?
    @taggable.destroy
    update_parent_tag
    @hierarchy_tree.calculate_tree(@taggable_class)
  end

  protected

  def update_parent_tag
    return if @parent_taggable.nil? || @parent_taggable.tag.nil?
    @parent_taggable.tag.write_taggable_data
  end
end
