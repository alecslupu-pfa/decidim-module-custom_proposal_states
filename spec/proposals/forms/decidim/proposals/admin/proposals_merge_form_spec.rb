# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe ProposalsMergeForm do
        subject { form }

        let(:proposals) { create_list(:extended_proposal, 3, component: component) }
        let(:component) { create(:extended_proposal_component) }
        let(:target_component) { create(:extended_proposal_component, participatory_space: component.participatory_space) }
        let(:params) do
          {
            target_component_id: [target_component.try(:id).to_s],
            proposal_ids: proposals.map(&:id)
          }
        end

        let(:form) do
          described_class.from_params(params).with_context(
            current_component: component,
            current_participatory_space: component.participatory_space
          )
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "without a target component" do
          let(:target_component) { nil }

          it { is_expected.to be_invalid }
        end

        context "when not enough proposals" do
          let(:proposals) { create_list(:extended_proposal, 1, component: component) }

          it { is_expected.to be_invalid }
        end

        context "when given a target component from another space" do
          let(:target_component) { create(:extended_proposal_component) }

          it { is_expected.to be_invalid }
        end

        context "when merging to the same component" do
          let(:target_component) { component }
          let(:proposals) { create_list(:extended_proposal, 3, :official, component: component) }

          context "when the proposal is not official" do
            let(:proposals) { create_list(:extended_proposal, 3, component: component) }

            it { is_expected.to be_invalid }
          end

          context "when a proposal has a vote" do
            before do
              create(:proposal_vote, proposal: proposals.sample)
            end

            it { is_expected.to be_invalid }
          end

          context "when a proposal has an endorsement" do
            before do
              create(:endorsement, resource: proposals.sample, author: create(:user, organization: component.participatory_space.organization))
            end

            it { is_expected.to be_invalid }
          end
        end
      end
    end
  end
end
