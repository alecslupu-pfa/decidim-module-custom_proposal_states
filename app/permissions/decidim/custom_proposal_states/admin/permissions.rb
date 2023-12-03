# frozen_string_literal: true

module Decidim
  module CustomProposalStates
    # This module contains all the domain logic associated to Decidim's CustomProposalStates
    # component admin panel.
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user
          # The public part needs to be implemented yet
          return permission_action if permission_action.scope != :admin

          if permission_action.subject == :proposal_state
            if permission_action.action == :destroy
              toggle_allow([proposal_state.system?, proposal_state.proposals.length.positive?].none?)
            else
              allow!
            end
          end

          permission_action
        end

        private

        def proposal_state
          @proposal_state ||= context.fetch(:proposal_state, nil)
        end
      end
    end
  end
end
