require 'rails_helper'

RSpec.describe "FoodRatingMetrics", type: :request do
  describe "GET /food_rating_metrics" do
    it "works! (now write some real specs)" do
      get food_rating_metrics_path
      expect(response).to have_http_status(200)
    end
  end
end
