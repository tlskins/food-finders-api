require 'rails_helper'

RSpec.describe "SocialEntries", type: :request do
  describe "GET /social_entries" do
    it "works! (now write some real specs)" do
      get social_entries_path
      expect(response).to have_http_status(200)
    end
  end
end
