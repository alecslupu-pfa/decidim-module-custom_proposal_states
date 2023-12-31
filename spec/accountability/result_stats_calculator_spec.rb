# frozen_string_literal: true

require "spec_helper"

module Decidim::Accountability
  describe ResultStatsCalculator do
    subject { described_class.new(result) }

    let(:participatory_process) { create(:participatory_process, :with_steps) }
    let(:current_component) { create :accountability_component, participatory_space: participatory_process }
    let(:scope) { create :scope, organization: current_component.organization }
    let(:parent_category) { create :category, participatory_space: current_component.participatory_space }
    let!(:result) do
      create(
        :result,
        component: current_component,
        category: parent_category,
        scope: scope
      )
    end
    let(:meetings_component) do
      create(:component, manifest_name: :meetings, participatory_space: participatory_process)
    end
    let(:meetings) do
      create_list(
        :meeting,
        3,
        component: meetings_component,
        attendees_count: 2,
        contributions_count: 5
      )
    end

    let(:proposals_component) do
      create(:extended_proposal_component, manifest_name: :proposals, participatory_space: participatory_process)
    end

    let(:proposals) do
      create_list(
        :extended_proposal,
        3,
        component: proposals_component
      )
    end

    before do
      result.link_resources(proposals, "included_proposals")
      result.link_resources(meetings, "meetings_through_proposals")
    end

    describe "votes_count" do
      before do
        proposals.each do |proposal|
          create(:proposal_vote, proposal: proposal)
        end
      end

      it "counts the votes of the related proposals" do
        expect(subject.votes_count).to eq 3
      end
    end
  end
end
