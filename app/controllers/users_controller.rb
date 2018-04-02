# User Controller
class UsersController < ApplicationController
  before_action(
    :set_user,
    only: %i[
      show
      update
      destroy
      newsfeed
      publish_draft_social_entry
      match_relationships
      update_relationship
    ]
  )

  def find_by_text(users, text)
    text_regex = Regexp.new(text, Regexp::IGNORECASE)
    users.where(
      :$or => [
        { first_name: text_regex },
        { last_name: text_regex },
        { handle: text_regex }
      ]
    )
  end

  # GET /users
  def index
    @users = User.all

    @users = find_by_text(@users, params[:text]) if params[:text].present?

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
    @social_entry = @user.publish_draft_social_entry(
      draft_social_entry_params[:text],
      draft_social_entry_params.to_h[:creatable_tags]
    )
    if @social_entry.valid?
      @user.reload
      render json: @user
    else
      render json: @social_entry.errors, status: :unprocessable_entity
    end
  end

  # GET /users/1/newsfeed
  def newsfeed
    newsfeed_items = @user.newsfeed(params[:created_after])
    if newsfeed_items.present?
      render json: newsfeed_items
    else
      render json: []
    end
  end

  # GET /users/1/match_relationships
  def match_relationships
    render json: @user.match_relationships(params[:user_ids].split(','))
  end

  # PATCH/PUT /users/1/update_relationship
  def update_relationship
    target = User.find(params[:target_id])
    @user.follow(target) if params[:type] == 'follow'
    @user.unfollow(target) if params[:type] == 'unfollow'

    if @user.reload
      render json: @user
    else
      render json: @user.errors, status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_user
    @user = User.find(params[:id])
  end

  def draft_social_entry_params
    params.permit(:text, creatable_tags: [
                    :name,
                    :symbol,
                    :handle,
                    :taggable_type,
                    taggable_object: [
                      :description,
                      :name,
                      :handle,
                      synonyms: []
                    ]
                  ])
  end

  def user_params
    params.require(:user).permit(
      draft_social_entry: [:text, { creatable_tags: [
        :name,
        :symbol,
        :handle,
        :taggable_type,
        taggable_object: [:description, :name, :handle, synonyms: []]
      ] }]
    )
  end
end
