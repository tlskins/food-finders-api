require "rails_helper"

RSpec.describe HashtagsController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/hashtags").to route_to("hashtags#index")
    end


    it "routes to #show" do
      expect(:get => "/hashtags/1").to route_to("hashtags#show", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/hashtags").to route_to("hashtags#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/hashtags/1").to route_to("hashtags#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/hashtags/1").to route_to("hashtags#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/hashtags/1").to route_to("hashtags#destroy", :id => "1")
    end

  end
end
