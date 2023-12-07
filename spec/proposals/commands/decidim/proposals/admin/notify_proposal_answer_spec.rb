# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Proposals
    module Admin
      describe NotifyProposalAnswer do
        subject { command.call }

        let(:command) { described_class.new(proposal, initial_state) }
        let!(:proposal) { create(:extended_proposal, :accepted) }
        let(:initial_state) { Decidim::CustomProposalStates::ProposalState.where(token: "not_answered", component: proposal.component).first! }
        let(:current_user) { create(:user, :admin) }
        let(:follow) { create(:follow, followable: proposal, user: follower) }
        let(:follower) { create(:user, organization: proposal.organization) }

        before do
          follow

          # give proposal author initial points to avoid unwanted events during tests
          Decidim::Gamification.increment_score(proposal.creator_author, :accepted_proposals)
        end

        it "broadcasts ok" do
          expect { subject }.to broadcast(:ok)
        end

        it "notifies the proposal followers" do
          expect(Decidim::EventsManager)
            .to receive(:publish)
            .with(
              event: "decidim.events.proposals.proposal_state_changed",
              event_class: Decidim::CustomProposalStates::ProposalStateChangedEvent,
              resource: proposal,
              affected_users: match_array([proposal.creator_author]),
              followers: match_array([follower])
            )

          subject
        end

        it "increments the accepted proposals counter" do
          expect { subject }.to change { Gamification.status_for(proposal.creator_author, :accepted_proposals).score }.by(1)
        end

        context "when the proposal is rejected after being accepted" do
          let(:proposal) { create(:extended_proposal, :rejected) }
          let(:initial_state) { Decidim::CustomProposalStates::ProposalState.find_by(token: "accepted", component: proposal.component) }

          it "broadcasts ok" do
            expect { subject }.to broadcast(:ok)
          end

          it "notifies the proposal followers" do
            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.proposals.proposal_state_changed",
                event_class: Decidim::CustomProposalStates::ProposalStateChangedEvent,
                resource: proposal,
                affected_users: match_array([proposal.creator_author]),
                followers: match_array([follower])
              )

            subject
          end

          it "decrements the accepted proposals counter" do
            expect { subject }.to change { Gamification.status_for(proposal.coauthorships.first.author, :accepted_proposals).score }.by(-1)
          end
        end

        context "when the proposal is not answered after being accepted" do
          let(:proposal) { create(:extended_proposal, answered_at: Time.current, state_published_at: Time.current) }
          let(:initial_state) { Decidim::CustomProposalStates::ProposalState.find_by(token: "accepted", component: proposal.component) }

          it "broadcasts ok" do
            expect { subject }.to broadcast(:ok)
          end

          it "doesn't notify the proposal followers" do
            expect(Decidim::EventsManager)
              .not_to receive(:publish)

            subject
          end

          it "decrements the accepted proposals counter" do
            expect { subject }.to change { Gamification.status_for(proposal.coauthorships.first.author, :accepted_proposals).score }.by(-1)
          end
        end

        context "when the proposal published state has not changed" do
          let(:initial_state) { Decidim::CustomProposalStates::ProposalState.find_by(token: "accepted", component: proposal.component) }

          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "doesn't notify the proposal followers" do
            expect(Decidim::EventsManager)
              .not_to receive(:publish)

            subject
          end

          it "doesn't modify the accepted proposals counter" do
            expect { subject }.not_to(change { Gamification.status_for(current_user, :accepted_proposals).score })
          end
        end

        context "when the proposal is nil" do
          let(:command) { described_class.new(nil, initial_state) }

          it "broadcasts invalid" do
            expect { subject }.to broadcast(:invalid)
          end
        end
      end
    end
  end
end
