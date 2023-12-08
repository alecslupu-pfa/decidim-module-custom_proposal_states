# frozen_string_literal: true

module Decidim
  module CustomProposalStates
    module Overrides
      module ProposalsHelper
        def self.prepended(base)
          base.class_eval do
            helper_method :available_states, :proposal_complete_state

            def available_states
              Decidim::CustomProposalStates::ProposalState.where(token: :not_answered, component: current_component) +
                Decidim::CustomProposalStates::ProposalState.answerable.where(component: current_component)
            end

            def proposal_complete_state(proposal)
              return humanize_proposal_state("not_answered").html_safe if proposal.proposal_state.nil?

              translated_attribute(proposal&.proposal_state&.title)
            end
          end
        end
      end
    end
  end
end
