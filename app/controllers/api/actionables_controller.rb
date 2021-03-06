class Api::ActionablesController < ApplicationController
  before_action :set_actionable, only: :show

  # GET /actionables
  def index
    @actionables = Action.public_scope.root_social_entries

    @actionables = @actionables.limit(20).order_by(conducted_at: :desc)

    render json: @actionables
  end

  # GET /find
  def find
    if params[:actionable_id].present?
      @actionable = Action.find_by_actionable_id(params[:actionable_id])
    elsif params[:social_entry_id].present?
      social_entry = SocialEntry.find_by(id: params[:social_entry_id])
      @actionable = social_entry.action if social_entry.present?
    elsif params[:social_entry_ids].present?
      @actionable = SocialEntry.find_by_ids(params[:social_entry_ids])
      @actionable = @actionable.entries.map(&:action)
    end

    if @actionable
      render json: @actionable
    else
      render(
        json: { message: 'Action not found.' },
        status: :unprocessable_entity
      )
    end
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
