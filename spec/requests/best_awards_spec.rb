require 'rails_helper'

RSpec.describe "BestAwards", type: :request do
  describe "GET /best_awards" do
    it "works! (now write some real specs)" do
      get best_awards_path
      expect(response).to have_http_status(200)
    end
  end
end
