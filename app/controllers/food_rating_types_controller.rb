class FoodRatingTypesController < ApplicationController
  before_action :set_food_rating_type, only: [:show]

  # GET /food_rating_types
  def index
    @food_rating_types = FoodRatingType.all

    render json: @food_rating_types
  end

  # GET /food_rating_types/1
  def show
    render json: @food_rating_type
  end

  # POST /food_rating_types
  def create
    generator = TaggableGenerator.new(FoodRatingType)

    @food_rating_type = generator.create_taggable(food_rating_type_params)
    if @food_rating_type.valid?
      render json: @food_rating_type
    else
      render json: @food_rating_type.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /food_rating_types/1
  def update
    generator = TaggableGenerator.new(FoodRatingType)

    @food_rating_type = generator.find_taggable(params[:id])
    if @food_rating_type.nil?
      render(
        json: { message: 'Taggable not found' },
        status: :unprocessable_entity
      )
    end

    @food_rating_type = generator.update_taggable(food_rating_type_params)
    if @food_rating_type.valid?
      render json: @food_rating_type
    else
      render json: @food_rating_type.errors, status: :unprocessable_entity
    end
  end

  # DELETE /food_rating_types/1
  def destroy
    generator = TaggableGenerator.new(FoodRatingType)

    @food_rating_type = generator.find_taggable(params[:id])
    if @food_rating_type.nil?
      render(
        json: { message: 'Taggable not found' },
        status: :unprocessable_entity
      )
    end

    generator.destroy_taggable
    render(
      json: { message: 'Deleted successfully.' },
      status: 200
    )
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_food_rating_type
      @food_rating_type = FoodRatingType.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def food_rating_type_params
      params.require(:food_rating_type).permit(
        :name,
        :parent_id,
        :description,
        synonyms: []
      )
    end
end
