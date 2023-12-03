# frozen_string_literal: true

module Decidim
  module CustomProposalStates
    # This is the engine that runs on the public interface of `CustomProposalStates`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::CustomProposalStates::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :proposal_states

        root to: "proposal_states#index"
      end

      initializer "decidim_custom_proposal_states_admin.mount_routes" do |_app|
        Decidim::Proposals::AdminEngine.routes do
          mount Decidim::CustomProposalStates::AdminEngine => "/proposal_states", as: "custom_proposal_states"
        end
      end

      def load_seed
        nil
      end
    end
  end
end
