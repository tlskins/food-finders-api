# User Controller
class UsersController < ApplicationController
  before_action(
    :set_user,
    only: %i[show update destroy newsfeed publish_draft_social_entry]
  )

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    render json: @user
  end

  # POST /users
  def create
    @user = User.new(user_params)

    if @user.save
      render json: @user, status: :created, location: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /users/1
  def update
    if @user.update(user_params)
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  # POST /users/1/publish_draft_social_entry
  def publish_draft_social_entry
    if @user.publish_draft_social_entry
      @user.reload
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  # GET /users/1/newsfeed
  def newsfeed
    newsfeed_items = @user.newsfeed(params[:created_after])
    if newsfeed_items.present?
      render json: newsfeed_items
    else
      render json: [], status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def user_params
    params.require(:user).permit(draft_social_entry: :text)
  end
end
