require 'rails_helper'

RSpec.describe "Hashtags", type: :request do
  describe "GET /hashtags" do
    it "works! (now write some real specs)" do
      get hashtags_path
      expect(response).to have_http_status(200)
    end
  end
end
