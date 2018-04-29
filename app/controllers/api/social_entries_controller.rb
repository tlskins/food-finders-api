# Social Entry controller
class Api::SocialEntriesController < ApplicationController
  before_action :set_social_entry, only: %i[show update destroy]

  # GET /social_entries
  def index
    @social_entries = SocialEntry.all

    render json: @social_entries
  end

  # GET /social_entries/1
  def show
    render json: @social_entry
  end

  # POST /social_entries
  def create
    @social_entry = SocialEntry.new(social_entry_params)

    if @social_entry.save
      render json: @social_entry, status: :created, location: @social_entry
    else
      render json: @social_entry.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /social_entries/1
  def update
    if @social_entry.update(social_entry_params)
      render json: @social_entry
    else
      render json: @social_entry.errors, status: :unprocessable_entity
    end
  end

  # DELETE /social_entries/1
  def destroy
    @social_entry.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_social_entry
    @social_entry = SocialEntry.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def social_entry_params
    params.require(:social_entry).permit(
      :text,
      :user_id,
      :vote,
      :tags,
      creatable_tags: []
    )
  end
end
