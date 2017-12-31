class BestAwardsController < ApplicationController
  before_action :set_best_award, only: [:show, :update, :destroy]

  # GET /best_awards
  def index
    @best_awards = BestAward.all

    render json: @best_awards
  end

  # GET /best_awards/1
  def show
    render json: @best_award
  end

  # POST /best_awards
  def create
    @best_award = BestAward.new(best_award_params)

    if @best_award.save
      render json: @best_award, status: :created, location: @best_award
    else
      render json: @best_award.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /best_awards/1
  def update
    if @best_award.update(best_award_params)
      render json: @best_award
    else
      render json: @best_award.errors, status: :unprocessable_entity
    end
  end

  # DELETE /best_awards/1
  def destroy
    @best_award.destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_best_award
      @best_award = BestAward.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def best_award_params
      params.require(:best_award).permit(:category)
    end
end
