# frozen_string_literal: true

require "rails"
require "deface"
require "decidim/core"

module Decidim
  module CustomProposalStates
    # This is the engine that runs on the public interface of custom_proposal_states.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::CustomProposalStates

      routes do
        # Add engine routes here
        # resources :custom_proposal_states
        # root to: "custom_proposal_states#index"
      end

      initializer "decidim_custom_proposal_states.views" do
        Rails.application.configure do
          config.deface.enabled = true
        end
      end

      # Subscribes to ActiveSupport::Notifications that may affect a Proposal.
      initializer "decidim_custom_proposal_states.subscribe_to_events" do
        # when a proposal is linked from a result
        event_name = "decidim.resourceable.included_proposals.created"

        ActiveSupport::Notifications.unsubscribe event_name

        ActiveSupport::Notifications.subscribe event_name do |_name, _started, _finished, _unique_id, data|
          payload = data[:this]
          if payload[:from_type] == Decidim::Accountability::Result.name && payload[:to_type] == Decidim::Proposals::Proposal.name
            proposal = Decidim::Proposals::Proposal.find(payload[:to_id])
            proposal.assign_state("accepted")
            proposal.update(state_published_at: Time.current)
          end
        end
      end

      initializer "decidim_custom_proposal_states.action_controller" do |_app|
        Rails.application.reloader.to_prepare do
          Decidim::Proposals::Proposal.prepend Decidim::CustomProposalStates::Overrides::Proposal
        end
      end
    end
  end
end
