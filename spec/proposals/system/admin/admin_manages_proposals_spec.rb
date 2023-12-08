# frozen_string_literal: true

require "spec_helper"

describe "Admin manages proposals", type: :system do
  let!(:proposal) { create :extended_proposal, component: current_component }
  let!(:reportables) { create_list(:extended_proposal, 3, component: current_component) }
  let(:participatory_space_path) do
    decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
  end

  include_context "when managing a component as an admin" do
    let!(:component) { create(:extended_proposal_component, participatory_space: participatory_process) }
  end

  it_behaves_like "manage proposals"
  it_behaves_like "manage moderations"
  it_behaves_like "export proposals"
  it_behaves_like "manage announcements"
  it_behaves_like "manage proposals help texts"
  it_behaves_like "when managing proposals category as an admin"
  it_behaves_like "when managing proposals scope as an admin"
  it_behaves_like "import proposals"
  it_behaves_like "manage proposals permissions"
  it_behaves_like "merge proposals"
  it_behaves_like "split proposals"
  it_behaves_like "publish answers"

  context "when answering a proposal" do
    shared_examples "can change state" do |state|
      it "can answer proposals" do
        within "form.edit_proposal_answer" do
          choose state
          fill_in_i18n_editor(
            :proposal_answer_answer,
            "#proposal_answer-answer-tabs",
            en: "This is my answer"
          )
          click_button "Answer"
        end
        expect(page).to have_content("successfully")
      end
    end

    before do
      visit current_path
      within find("tr", text: translated(proposal.title)) do
        click_link "Answer proposal"
      end
    end

    include_examples "can change state", "Accepted"

    context "when there are custom states involved" do
      let(:state_params) do
        {
          title: { en: "Custom state" },
          token: "custom_state",
          css_class: "custom-state",
          system: false
        }
      end
      let!(:custom_state) { create(:proposal_state, **state_params, answerable: true, component: proposal.component) }

      before { visit current_path }

      it "successfully displays the new state" do
        expect(page).to have_content("Custom state")
      end

      include_examples "can change state", "Custom state"
    end
  end
end
