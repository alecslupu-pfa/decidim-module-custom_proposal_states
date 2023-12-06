# frozen_string_literal: true

module Decidim
  module CustomProposalStates
    module Overrides
      module WithdrawProposal
        def self.prepended(base)
          base.class_eval do
            def change_proposal_state_to_withdrawn
              @proposal.assign_state("withdrawn")
              @proposal.save
            end
          end
        end
      end
    end
  end
end
