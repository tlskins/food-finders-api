# Tag controller
class TagsController < ApplicationController
  before_action :set_tag, only: %i[show update destroy]

  # GET /all_roots
  def all_roots
    @all_roots = { '@' => {}, '#' => {}, '^' => {}, '&' => {} }
    FoodRatingType.roots.select { |r| r.tag.present? }.map(&:tag).each do |tag|
      @all_roots['#'][tag.handle] = tag
      @all_roots['#']['roots'] ||= []
      @all_roots['#']['roots'] << tag
    end
    FoodRatingMetric.roots.select { |r| r.tag.present? }.map(&:tag).each do |tag|
      @all_roots['&'][tag.handle] = tag
      @all_roots['&']['roots'] ||= []
      @all_roots['&']['roots'] << tag
    end

    render json: @all_roots
  end

  # GET /tags
  def index
    @tags = Tag.all

    @tags = @tags.find_by_symbol(params[:symbol]) if params[:symbol].present?

    @tags = @tags.find_by_text(params[:text]) if params[:text].present?

    @tags = @tags.find_by_path(params[:path]) if params[:path].present?

    @tags = @tags.find_by_handles(params[:handles]) if params[:handles].present?

    page = (params[:page] || 1).to_i
    results_per_page = (params[:results_per_page] || 5).to_i

    start_index = (page - 1) * results_per_page
    end_index = start_index + results_per_page - 1

    @tags = @tags.entries[start_index..end_index]

    render json: @tags
  end

  # GET /tags/1
  def show
    render json: @tag
  end

  # POST /tags
  def create
    @tag = Tag.new(tag_params)

    if @tag.save
      render json: @tag, status: :created, location: @tag
    else
      render json: @tag.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /tags/1
  def update
    if @tag.update(tag_params)
      render json: @tag
    else
      render json: @tag.errors, status: :unprocessable_entity
    end
  end

  # DELETE /tags/1
  def destroy
    @tag.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_tag
    @tag = Tag.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def tag_params
    params.require(:tag).permit(:taggable_symbol, :taggable_name)
  end
end
