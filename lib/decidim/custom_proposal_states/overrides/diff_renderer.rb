# frozen_string_literal: true

module Decidim
  module CustomProposalStates
    module Overrides
      module DiffRenderer
        def self.prepended(base)
          base.class_eval do
            # Lists which attributes will be diffable and how they should be rendered.
            def attribute_types
              {
                title: :i18n,
                body: :i18n,
                decidim_category_id: :category,
                decidim_scope_id: :scope,
                address: :string,
                latitude: :string,
                longitude: :string,
                decidim_proposals_proposal_state_id: :string
              }
            end
          end
        end
      end
    end
  end
end
