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

      initializer "decidim_custom_proposal_states.action_controller" do |_app|
        Rails.application.reloader.to_prepare do
          Decidim::Proposals::Proposal.prepend Decidim::CustomProposalStates::Overrides::Proposal
        end
      end
    end
  end
end
