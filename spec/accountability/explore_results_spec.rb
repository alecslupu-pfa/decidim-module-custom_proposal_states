# frozen_string_literal: true

require "spec_helper"

describe "Explore results", versioning: true, type: :system do
  include_context "with a component"

  let(:manifest_name) { "accountability" }
  let(:results_count) { 5 }
  let!(:scope) { create :scope, organization: organization }
  let!(:results) do
    create_list(
      :result,
      results_count,
      component: component
    )
  end

  before do
    component.update(settings: { scopes_enabled: true })
    visit path
  end

  describe "show" do
    let(:path) { decidim_participatory_process_accountability.result_path(id: result.id, participatory_process_slug: participatory_process.slug, component_id: component.id) }
    let(:results_count) { 1 }
    let(:result) { results.first }

    context "with linked proposals" do
      let(:proposal_component) do
        create(:extended_proposal_component, manifest_name: :proposals, participatory_space: result.component.participatory_space)
      end
      let(:proposals) { create_list(:extended_proposal, 3, component: proposal_component) }
      let(:proposal) { proposals.first }

      before do
        result.link_resources(proposals, "included_proposals")
        visit current_path
      end

      it "shows related proposals" do
        proposals.each do |proposal|
          expect(page).to have_content(translated(proposal.title))
          expect(page).to have_content(proposal.creator_author.name)
          expect(page).to have_content(proposal.votes.size)
        end
      end

      it "the result is mentioned in the proposal page" do
        click_link translated(proposal.title)
        expect(page).to have_i18n_content(result.title)
      end
    end
  end
end
