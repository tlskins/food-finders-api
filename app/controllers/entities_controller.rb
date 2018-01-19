class EntitiesController < ApplicationController
  before_action :set_entity, only: [:show, :update, :destroy]

  # GET /entities
  def index
    @entities = Entity.all

    if params[:business_ids].present?
      @entities = @entities.where("business.id": { '$in': params[:business_ids].split(",") } ) if params[:business_ids].present?
    end

    render json: @entities
  end

  # GET /entities/1
  def show
    render json: @entity
  end

  # POST /entities
  def create
    @entity = Entity.new(entity_params)

    if @entity.save
      render json: @entity, status: :created, location: @entity
    else
      render json: @entity.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /entities/1
  def update
    if @entity.update(entity_params)
      render json: @entity
    else
      render json: @entity.errors, status: :unprocessable_entity
    end
  end

  # DELETE /entities/1
  def destroy
    @entity.destroy
  end

  private

    # Use callbacks to share common setup or constraints between actions.
    def set_entity
      @entity = Entity.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def entity_params
      load_params = params.require(:entity).permit()
      # Dont want to whitelist yelp business hash as that may change in the future
      load_params[:yelp_business] = params[:entity][:yelp_business]
      load_params.permit!
    end
end
