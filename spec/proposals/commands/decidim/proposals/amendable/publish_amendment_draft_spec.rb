# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe PublishDraft do
      let!(:component) { create(:extended_proposal_component) }
      let!(:other_user) { create(:user, :confirmed, organization: component.organization) }

      let!(:amendable) { create(:extended_proposal, component: component) }
      let!(:emendation) { create(:extended_proposal, :unpublished, component: component) }
      let!(:amendment) { create(:amendment, :draft, amendable: amendable, emendation: emendation) }

      let(:current_user) { amendment.amender }
      let(:context) do
        {
          current_user: current_user,
          current_organization: component.organization
        }
      end

      let(:form) { Decidim::Amendable::PublishForm.from_model(amendment).with_context(context) }
      let(:command) { described_class.new(form) }

      include_examples "publish amendment draft" do
        it "changes the emendation state" do
          not_answered = Decidim::CustomProposalStates::ProposalState.where(component: component, token: "not_answered").pick(:id)
          evaluating = Decidim::CustomProposalStates::ProposalState.where(component: component, token: "evaluating").pick(:id)
          expect { command.call }.to change { emendation.reload[:decidim_proposals_proposal_state_id] }.from(not_answered).to(evaluating)
        end
      end
    end
  end
end
