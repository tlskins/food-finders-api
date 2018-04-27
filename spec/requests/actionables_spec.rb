require 'rails_helper'

RSpec.describe "Actionables", type: :request do
  describe "GET /actionables" do
    it "works! (now write some real specs)" do
      get actionables_path
      expect(response).to have_http_status(200)
    end
  end
end
