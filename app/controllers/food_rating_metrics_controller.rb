class FoodRatingMetricsController < ApplicationController
  before_action :set_food_rating_metric, only: [:show, :update, :destroy]

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
    @food_rating_metric = FoodRatingMetric.new(food_rating_metric_params)

    if @food_rating_metric.save
      render json: @food_rating_metric, status: :created, location: @food_rating_metric
    else
      render json: @food_rating_metric.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /food_rating_metrics/1
  def update
    if @food_rating_metric.update(food_rating_metric_params)
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
      params.fetch(:food_rating_metric, {})
    end
end
