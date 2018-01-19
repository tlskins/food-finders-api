require "rails_helper"

RSpec.describe SocialEntriesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/social_entries").to route_to("social_entries#index")
    end


    it "routes to #show" do
      expect(:get => "/social_entries/1").to route_to("social_entries#show", :id => "1")
    end


    it "routes to #create" do
      expect(:post => "/social_entries").to route_to("social_entries#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/social_entries/1").to route_to("social_entries#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/social_entries/1").to route_to("social_entries#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/social_entries/1").to route_to("social_entries#destroy", :id => "1")
    end

  end
end
