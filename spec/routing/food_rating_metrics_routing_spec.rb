require "rails_helper"

RSpec.describe FoodRatingMetricsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/food_rating_metrics").to route_to("food_rating_metrics#index")
    end


    it "routes to #show" do
      expect(:get => "/food_rating_metrics/1").to route_to("food_rating_metrics#show", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/food_rating_metrics").to route_to("food_rating_metrics#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/food_rating_metrics/1").to route_to("food_rating_metrics#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/food_rating_metrics/1").to route_to("food_rating_metrics#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/food_rating_metrics/1").to route_to("food_rating_metrics#destroy", :id => "1")
    end

  end
end
