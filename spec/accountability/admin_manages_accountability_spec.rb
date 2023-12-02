# frozen_string_literal: true

require "spec_helper"
require "decidim/proposals/test/capybara_proposals_picker"

describe "Admin manages accountability", type: :system do
  let(:manifest_name) { "accountability" }

  include_context "when managing an accountability component as an admin"

  before do
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin
  end

  describe "results" do
    it_behaves_like "manage results"
  end
end
