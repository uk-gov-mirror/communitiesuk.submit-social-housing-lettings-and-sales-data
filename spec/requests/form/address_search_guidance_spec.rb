require "rails_helper"

RSpec.describe "Address search bottom guidance", type: :request do
  let(:user) { create(:user) }

  before { sign_in user }

  context "with a 2026 lettings log at the address search question" do
    let(:lettings_log) { create(:lettings_log, :completed, assigned_to: user, manual_address_entry_selected: false) }

    it "shows the confidential supported lettings guidance drop-down" do
      get "/lettings-logs/#{lettings_log.id}/address-search"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("What should I do for confidential supported lettings?")
      expect(response.body).to include("Full address or UPRN is not required for confidential supported lettings.")
    end
  end

  context "with a 2026 sales log at the address search question" do
    let(:sales_log) { create(:sales_log, :completed, assigned_to: user, manual_address_entry_selected: false) }

    it "does not show the lettings confidential supported lettings guidance" do
      get "/sales-logs/#{sales_log.id}/address-search"

      expect(response.body).not_to include("What should I do for confidential supported lettings?")
    end
  end
end
