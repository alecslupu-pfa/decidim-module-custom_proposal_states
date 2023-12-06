# frozen_string_literal: true

module Decidim
  module CustomProposalStates
    module Overrides
      module ImportProposals
        def self.prepended(base)
          base.class_eval do
            def proposals
              @proposals = Decidim::Proposals::Proposal
                           .where(component: origin_component)
                           .only_status(@form.states)
              @proposals = @proposals.where(scope: proposal_scopes) unless proposal_scopes.empty?
              @proposals
            end

            def proposal_answer_attributes(original_proposal)
              return {} unless form.keep_answers

              state = Decidim::CustomProposalStates::ProposalState.where(component: target_component, token: original_proposal.state).first!

              {
                answer: original_proposal.answer,
                answered_at: original_proposal.answered_at,
                proposal_state: state,
                state_published_at: original_proposal.state_published_at
              }
            end
          end
        end
      end
    end
  end
end
