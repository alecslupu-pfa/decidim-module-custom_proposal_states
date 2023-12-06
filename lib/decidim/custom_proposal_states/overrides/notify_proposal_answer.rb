# frozen_string_literal: true

module Decidim
  module CustomProposalStates
    module Overrides
      module NotifyProposalAnswer
        def self.prepended(base)
          base.class_eval do
            def initialize(proposal, initial_state)
              @proposal = proposal
              @initial_state = initial_state
            end

            def state_changed?
              initial_state != proposal.proposal_state
            end

            def notify_followers
              return unless proposal.proposal_state.notifiable?

              Decidim::EventsManager.publish(
                event: "decidim.events.proposals.proposal_state_changed",
                event_class: Decidim::CustomProposalStates::ProposalStateChangedEvent,
                resource: proposal,
                affected_users: proposal.notifiable_identities,
                followers: proposal.followers - proposal.notifiable_identities
              )
            end

            def increment_score
              previously_gamified = initial_state.present? && initial_state.gamified?

              if !previously_gamified && proposal.proposal_state.gamified?
                proposal.coauthorships.find_each do |coauthorship|
                  Decidim::Gamification.increment_score(coauthorship.user_group || coauthorship.author, :accepted_proposals)
                end
              elsif previously_gamified && !proposal.proposal_state.gamified?
                proposal.coauthorships.find_each do |coauthorship|
                  Decidim::Gamification.decrement_score(coauthorship.user_group || coauthorship.author, :accepted_proposals)
                end
              end
            end
          end
        end
      end
    end
  end
end
