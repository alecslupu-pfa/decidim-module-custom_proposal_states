# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe Accept do
      let!(:component) { create(:extended_proposal_component) }
      let!(:amendable) { create(:extended_proposal, component: component) }
      let!(:emendation) { create(:extended_proposal, component: component) }
      let!(:amendment) { create :amendment, amendable: amendable, emendation: emendation }
      let(:command) { described_class.new(form) }

      let(:emendation_params) do
        {
          title: translated(emendation.title),
          body: translated(emendation.body)
        }
      end

      let(:form_params) do
        {
          id: amendment.id,
          emendation_params: emendation_params
        }
      end

      let(:form) { Decidim::Amendable::ReviewForm.from_params(form_params) }

      include_examples "accept amendment" do
        it "changes the emendation state" do
          not_answered = Decidim::CustomProposalStates::ProposalState.where(component: component, token: "not_answered").pick(:id)
          accepted = Decidim::CustomProposalStates::ProposalState.where(component: component, token: "accepted").pick(:id)
          expect { command.call }.to change { emendation.reload[:decidim_proposals_proposal_state_id] }.from(not_answered).to(accepted)
        end
      end
    end
  end
end
