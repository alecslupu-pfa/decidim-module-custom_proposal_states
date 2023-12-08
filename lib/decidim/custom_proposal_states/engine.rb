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

      initializer "decidim_custom_proposal_states.overrides.budgets" do
        Rails.application.reloader.to_prepare do
          return unless Decidim.module_installed?("budgets")

          Decidim::Budgets::Admin::ImportProposalsToBudgets.prepend Decidim::CustomProposalStates::Overrides::ImportProposalsToBudgets
        end
      end

      initializer "decidim_custom_proposal_states.overrides.elections" do
        Rails.application.reloader.to_prepare do
          return unless Decidim.module_installed?("elections")

          Decidim::Elections::Admin::ImportProposalsToElections.prepend Decidim::CustomProposalStates::Overrides::ImportProposalsToElections
        end
      end
      initializer "decidim_custom_proposal_states.action_controller", after: "decidim.action_controller" do
        config.to_prepare do
          ActiveSupport.on_load :action_controller do
            Decidim::Proposals::Admin::ApplicationController.prepend Decidim::CustomProposalStates::Overrides::ProposalsHelper
            Decidim::Proposals::Admin::ProposalsController.prepend Decidim::CustomProposalStates::Overrides::AdminFilterable
            Decidim::Proposals::Admin::ProposalAnswersController.prepend Decidim::CustomProposalStates::Overrides::ProposalAnswersController
          end
        end
      end

      initializer "decidim_custom_proposal_states.overrides.proposal" do
        Rails.application.reloader.to_prepare do
          Decidim::Amendable::AnnouncementCell.prepend Decidim::CustomProposalStates::Overrides::AnnouncementCell

          Decidim::Proposals::Proposal.prepend Decidim::CustomProposalStates::Overrides::Proposal
          Decidim::Proposals::WithdrawProposal.prepend Decidim::CustomProposalStates::Overrides::WithdrawProposal
          Decidim::Proposals::Admin::ImportProposals.prepend Decidim::CustomProposalStates::Overrides::ImportProposals
          Decidim::Proposals::Admin::AnswerProposal.prepend Decidim::CustomProposalStates::Overrides::AnswerProposal
          Decidim::Proposals::Admin::NotifyProposalAnswer.prepend Decidim::CustomProposalStates::Overrides::NotifyProposalAnswer
          Decidim::Proposals::Import::ProposalAnswerCreator.prepend Decidim::CustomProposalStates::Overrides::ProposalAnswerCreator
          Decidim::Proposals::ProposalPresenter.prepend Decidim::CustomProposalStates::Overrides::ProposalPresenter
          Decidim::Proposals::DiffRenderer.prepend Decidim::CustomProposalStates::Overrides::DiffRenderer
        end
      end

      initializer "decidim_custom_proposal_states.patch_engine" do
        Rails.application.reloader.to_prepare do
          return unless Decidim.module_installed?("proposals")
          return if Decidim::Gamification.find_badge(:accepted_proposals).blank?

          Decidim::Gamification.find_badge(:accepted_proposals).reset = lambda { |model|
            proposal_ids = case model
                           when User
                             Decidim::Coauthorship.where(
                               coauthorable_type: "Decidim::Proposals::Proposal",
                               author: model,
                               user_group: nil
                             ).select(:coauthorable_id)
                           when UserGroup
                             Decidim::Coauthorship.where(
                               coauthorable_type: "Decidim::Proposals::Proposal",
                               user_group: model
                             ).select(:coauthorable_id)
                           end

            Decidim::Proposals::Proposal.where(id: proposal_ids).gamified.count
          }
        end
      end

      initializer "decidim_custom_proposal_states.patch_component" do
        Rails.application.reloader.to_prepare do
          return unless Decidim.module_installed?("proposals")

          Decidim.find_component_manifest(:proposals).on(:create) do |instance|
            admin_user = GlobalID::Locator.locate(instance.versions.first.whodunnit)
            Decidim::Proposals.create_default_states!(instance, admin_user)
          end
        end
      end
    end
  end
end
