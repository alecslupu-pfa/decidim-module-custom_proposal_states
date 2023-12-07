# frozen_string_literal: true

module Decidim
  module CustomProposalStates
    module Overrides
      module ProposalAnswerCreator
        def self.prepended(base)
          base.class_eval do
            def fetch_resource
              proposal = Decidim::Proposals::Proposal.find_by(id: id)
              return nil unless proposal
              return nil if proposal.emendation?

              if proposal.component != component
                proposal.errors.add(:component, :invalid)
                return proposal
              end

              proposal.answer = answer
              proposal.answered_at = Time.current
              @initial_state = proposal.proposal_state

              proposal_state = Decidim::CustomProposalStates::ProposalState.find_by(component: component, token: state)

              if proposal_state&.answerable?
                proposal.proposal_state = proposal_state
                proposal.state_published_at = Time.current if component.current_settings.publish_answers_immediately?
              else
                proposal.errors.add(:state, :invalid)
              end
              proposal
            end
          end
        end
      end
    end
  end
end
