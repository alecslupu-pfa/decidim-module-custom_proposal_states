# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe Withdraw do
      let!(:component) { create(:extended_proposal_component) }
      let!(:other_user) { create(:user, :confirmed, organization: component.organization) }

      let!(:amendable) { create(:extended_proposal, component: component) }
      let!(:emendation) { create(:extended_proposal, component: component) }
      let!(:amendment) { create :amendment, amendable: amendable, emendation: emendation, amender: emendation.creator_author }

      let(:command) { described_class.new(amendment, current_user) }
      let(:current_user) { amendment.amender }

      include_examples "withdraw amendment" do
        it "changes the emendation state" do
          not_answered = Decidim::CustomProposalStates::ProposalState.where(component: component, token: "not_answered").pick(:id)
          withdrawn = Decidim::CustomProposalStates::ProposalState.where(component: component, token: "withdrawn").pick(:id)
          expect { command.call }.to change { emendation.reload[:decidim_proposals_proposal_state_id] }.from(not_answered).to(withdrawn)
        end
      end
    end
  end
end
