class Api::ActionablesController < ApplicationController
  before_action :set_actionable, only: :show

  # GET /actionables
  def index
    @actionables = Action.all

    if params[:actionable_id].present?
      @actionables = @actionables.find_by_actionable_id(params[:actionable_id])
    end

    @actionables = @actionables.limit(20).order_by(conducted_at: :desc)

    render json: @actionables
  end

  # GET /actionables/1
  def show
    render json: @actionable
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_actionable
    @actionable = Actionable.find(params[:id])
  end
end
