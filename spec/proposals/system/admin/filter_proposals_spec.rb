# frozen_string_literal: true

require "spec_helper"

describe "Admin filters proposals", type: :system do
  include_context "when admin manages proposals"
  include_context "with filterable context" do
    let!(:factory_name) { :extended_proposal }
  end

  STATES = {
    not_answered: "Not answered",
    evaluating: "Evaluating",
    accepted: "Accepted",
    rejected: "Rejected",
    withdrawn: "Withdrawn",
    custom_state: "Custom state"
  }.freeze

  let(:model_name) { Decidim::Proposals::Proposal.model_name }
  let(:resource_controller) { Decidim::Proposals::Admin::ProposalsController }
  let!(:component) { create(:extended_proposal_component, participatory_space: participatory_process) }
  let!(:custom_state) { create(:proposal_state, component: component, token: :custom_state, title: { "en" => "Custom state" }) }

  def create_extended_proposal_with_trait(trait)
    create(:extended_proposal, trait, component: component, skip_injection: true)
  end

  def extended_proposal_with_state(state)
    proposal_state = Decidim::CustomProposalStates::ProposalState.find_by(component: component, token: state)
    Decidim::Proposals::Proposal.where(component: component).find_by(proposal_state: proposal_state)
  end

  def extended_proposal_without_state(state)
    proposal_state = Decidim::CustomProposalStates::ProposalState.find_by(component: component, token: state)
    Decidim::Proposals::Proposal.where(component: component).where.not(proposal_state: proposal_state).sample
  end

  context "when filtering by state" do
    let!(:proposals) do
      STATES.keys.map { |state| create_extended_proposal_with_trait(state) }
    end

    before { visit_component_admin }

    STATES.each_pair do |state, value|
      context "filtering proposals by state: #{value}" do
        it_behaves_like "a filtered collection", options: "State", filter: value do
          let!(:factory_name) { :extended_proposal }
          let(:in_filter) { translated(extended_proposal_with_state(state).title) }
          let(:not_in_filter) { translated(extended_proposal_without_state(state).title) }
        end
      end
    end
  end

  context "when filtering by type" do
    let!(:emendation) { create(:extended_proposal, component: component, skip_injection: true) }
    let(:emendation_title) { translated(emendation.title) }
    let!(:amendable) { create(:extended_proposal, component: component, skip_injection: true) }
    let(:amendable_title) { translated(amendable.title) }
    let!(:amendment) { create(:amendment, amendable: amendable, emendation: emendation) }

    before { visit_component_admin }

    it_behaves_like "a filtered collection", options: "Type", filter: "Proposals" do
      let(:in_filter) { amendable_title }
      let(:not_in_filter) { emendation_title }
    end

    it_behaves_like "a filtered collection", options: "Type", filter: "Amendments" do
      let(:in_filter) { emendation_title }
      let(:not_in_filter) { amendable_title }
    end
  end

  context "when filtering by scope" do
    let!(:scope1) { create(:scope, organization: organization, name: { "en" => "Scope1" }) }
    let!(:scope2) { create(:scope, organization: organization, name: { "en" => "Scope2" }) }
    let!(:proposal_with_scope1) { create(:extended_proposal, component: component, skip_injection: true, scope: scope1) }
    let(:proposal_with_scope1_title) { translated(proposal_with_scope1.title) }
    let!(:proposal_with_scope2) { create(:extended_proposal, component: component, skip_injection: true, scope: scope2) }
    let(:proposal_with_scope2_title) { translated(proposal_with_scope2.title) }

    before { visit_component_admin }

    it_behaves_like "a filtered collection", options: "Scope", filter: "Scope1" do
      let(:in_filter) { proposal_with_scope1_title }
      let(:not_in_filter) { proposal_with_scope2_title }
    end

    it_behaves_like "a filtered collection", options: "Scope", filter: "Scope2" do
      let(:in_filter) { proposal_with_scope2_title }
      let(:not_in_filter) { proposal_with_scope1_title }
    end
  end

  context "when searching by ID or title" do
    let!(:proposal1) { create(:extended_proposal, component: component, skip_injection: true) }
    let!(:proposal2) { create(:extended_proposal, component: component, skip_injection: true) }
    let!(:proposal1_title) { translated(proposal1.title) }
    let!(:proposal2_title) { translated(proposal2.title) }

    before { visit_component_admin }

    it "can be searched by ID" do
      search_by_text(proposal1.id)

      expect(page).to have_content(proposal1_title)
    end

    it "can be searched by title" do
      search_by_text(proposal2_title)

      expect(page).to have_content(proposal2_title)
    end
  end

  it_behaves_like "paginating a collection" do
    let!(:collection) { create_list(:extended_proposal, 50, component: component, skip_injection: true) }
  end
end
