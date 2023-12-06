# frozen_string_literal: true

require "spec_helper"
require "decidim/proposals/test/capybara_proposals_picker"

describe "Admin manages projects", type: :system do
  let(:manifest_name) { "budgets" }
  let(:budget) { create :budget, component: current_component }
  let!(:project) { create :project, budget: budget }

  include_context "when managing a component as an admin"

  before do
    budget
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin

    within find("tr", text: translated(budget.title)) do
      page.find(".action-icon--edit-projects").click
    end
  end

  context "when importing proposals to projects" do
    let!(:proposals) { create_list :extended_proposal, 3, :accepted, component: origin_component }
    let!(:rejected_proposals) { create_list :extended_proposal, 3, :rejected, component: origin_component }
    let!(:origin_component) { create :extended_proposal_component, participatory_space: current_component.participatory_space }
    let!(:default_budget) { 2333 }

    include Decidim::ComponentPathHelper

    it "imports proposals from one component to a budget component" do
      click_link "Import proposals to projects"

      within ".import_proposals" do
        select origin_component.name["en"], from: :proposals_import_origin_component_id
        fill_in "Default budget", with: default_budget
        check :proposals_import_import_all_accepted_proposals
      end

      click_button "Import proposals to projects"

      expect(page).to have_content("3 proposals successfully imported")

      proposals.each do |project|
        expect(page).to have_content(project.title["en"])
      end
    end
  end
end
