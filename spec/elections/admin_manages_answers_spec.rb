# frozen_string_literal: true

require "spec_helper"

describe "Admin manages answers", type: :system do
  let!(:proposals) { create_list :extended_proposal, 3, :accepted, component: origin_component }
  let!(:origin_component) { create :extended_proposal_component, participatory_space: current_component.participatory_space }
  let(:election) { create :election, component: current_component }
  let(:question) { create :question, election: election }
  let(:answer) { create :election_answer, question: question }
  let(:manifest_name) { "elections" }

  include_context "when managing a component as an admin"

  before do
    answer
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin

    within find("tr", text: translated(election.title)) do
      page.find(".action-icon--manage-questions").click
    end

    within find("tr", text: translated(question.title)) do
      page.find(".action-icon--manage-answers").click
    end
  end

  describe "importing proposals" do
    it "imports proposals" do
      click_on "Import proposals to answers"

      within ".import_proposals" do
        select origin_component.name["en"], from: :proposals_import_origin_component_id
        check :proposals_import_import_all_accepted_proposals
      end

      click_button "Import proposals to answers"

      expect(page).to have_content("3 proposals successfully imported")
    end
  end
end
