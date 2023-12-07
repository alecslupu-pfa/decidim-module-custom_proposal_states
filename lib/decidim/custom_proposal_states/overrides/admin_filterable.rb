# frozen_string_literal: true

module Decidim
  module CustomProposalStates
    module Overrides
      module AdminFilterable
        # extend ActiveSupport::Concern
        #
        # included do
        def filters
          [
            :is_emendation_true,
            :proposal_state_id_eq,
            :scope_id_eq,
            :category_id_eq,
            :valuator_role_ids_has
          ]
        end

        def filters_with_values
          {
            is_emendation_true: %w(true false),
            proposal_state_id_eq: proposal_state_ids,
            scope_id_eq: scope_ids_hash(scopes.top_level),
            category_id_eq: category_ids_hash(categories.first_class),
            valuator_role_ids_has: valuator_role_ids
          }
        end

        def dynamically_translated_filters
          [:scope_id_eq, :category_id_eq, :valuator_role_ids_has, :proposal_state_id_eq]
        end

        def proposal_state_ids
          Decidim::CustomProposalStates::ProposalState.where(component: current_component).pluck(:id)
        end

        def translated_proposal_state_id_eq(state_id)
          translated_attribute(Decidim::CustomProposalStates::ProposalState.find_by(component: current_component, id: state_id)&.title)
        end
        # end
      end
    end
  end
end
