# frozen_string_literal: true

module Decidim
  module CustomProposalStates
    module Overrides
      module ImportProposalsToElections
        def self.prepended(base)
          base.class_eval do
            def proposals
              @proposals ||= if @form.import_all_accepted_proposals?
                               Decidim::Proposals::Proposal.where(component: origin_component).only_status(:accepted)
                             else
                               Decidim::Proposals::Proposal.where(component: origin_component)
                             end
            end
          end
        end
      end
    end
  end
end
