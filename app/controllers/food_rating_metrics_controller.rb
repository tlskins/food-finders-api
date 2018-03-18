class FoodRatingMetricsController < ApplicationController
  before_action :set_food_rating_metric, only: [:show, :destroy]

  # GET /food_rating_metrics
  def index
    @food_rating_metrics = FoodRatingMetric.all

    render json: @food_rating_metrics
  end

  # GET /food_rating_metrics/1
  def show
    render json: @food_rating_metric
  end

  # POST /food_rating_metrics
  def create
    generator = TaggableGenerator.new(FoodRatingMetric)

    @food_rating_metric = generator.create_taggable(food_rating_metric_params)
    if @food_rating_metric.valid?
      render json: @food_rating_metric
    else
      render json: @food_rating_metric.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /food_rating_metrics/1
  def update
    generator = TaggableGenerator.new(FoodRatingMetric)

    @food_rating_metric = generator.find_taggable(params[:id])
    if @food_rating_metric.nil?
      render(
        json: { message: 'Taggable not found' },
        status: :unprocessable_entity
      )
    end

    @food_rating_metric = generator.update_taggable(food_rating_metric_params)
    if @food_rating_metric.valid?
      render json: @food_rating_metric
    else
      render json: @food_rating_metric.errors, status: :unprocessable_entity
    end
  end

  # DELETE /food_rating_metrics/1
  def destroy
    @food_rating_metric.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_food_rating_metric
      @food_rating_metric = FoodRatingMetric.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def food_rating_metric_params
      params.require(:food_rating_metric).permit(
        :name,
        :parent_id,
        :description,
        synonyms: []
      )
    end
end
