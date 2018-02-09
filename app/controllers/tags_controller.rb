# Tag controller
class TagsController < ApplicationController
  before_action :set_tag, only: %i[show update destroy]

  def find_by_symbol(tags, symbol)
    parsed_symbol = symbol == '%23' ? '#' : symbol
    tags.where(symbol: parsed_symbol)
  end

  def find_by_text(tags, text)
    text_regex = Regexp.new(text, Regexp::IGNORECASE)
    tags.where(
      :$or => [
        { name: text_regex },
        { handle: text_regex }
      ]
    )
  end

  # GET /tags
  def index
    @tags = Tag.all

    @tags = find_by_symbol(@tags, params[:symbol]) if params[:symbol].present?

    @tags = find_by_text(@tags, params[:text]) if params[:text].present?

    render json: @tags
  end

  # GET /tags/1
  def show
    render json: @tag
  end

  # POST /tags
  def create
    @tag = Tag.new(tag_params)

    if @tag.save
      render json: @tag, status: :created, location: @tag
    else
      render json: @tag.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /tags/1
  def update
    if @tag.update(tag_params)
      render json: @tag
    else
      render json: @tag.errors, status: :unprocessable_entity
    end
  end

  # DELETE /tags/1
  def destroy
    @tag.destroy
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_tag
    @tag = Tag.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def tag_params
    params.require(:tag).permit(:taggable_symbol, :taggable_name)
  end
end
