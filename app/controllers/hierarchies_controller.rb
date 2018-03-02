# Hierarchies controller
class HierarchyTreesController < ApplicationController
  # GET /hierarchies
  def index
    @hierarchy_trees = HierarchyTree.all

    if params[:class_name].present?
      @hierarchy_trees = @entities.where(class_name: params[:class_name])
    end

    render json: @hierarchy_trees
  end
end
