require "rails_helper"

RSpec.describe BestAwardsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/best_awards").to route_to("best_awards#index")
    end


    it "routes to #show" do
      expect(:get => "/best_awards/1").to route_to("best_awards#show", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/best_awards").to route_to("best_awards#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/best_awards/1").to route_to("best_awards#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/best_awards/1").to route_to("best_awards#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/best_awards/1").to route_to("best_awards#destroy", :id => "1")
    end

  end
end
