# frozen_string_literal: true

module Decidim
  module CustomProposalStates
    module Overrides
      module ImportProposalsToBudgets
        def self.prepended(base)
          base.class_eval do
            def all_proposals
              Decidim::Proposals::Proposal.where(component: origin_component).only_status(:accepted)
            end
          end
        end
      end
    end
  end
end
