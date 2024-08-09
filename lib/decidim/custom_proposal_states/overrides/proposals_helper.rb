# frozen_string_literal: true

module Decidim
  module CustomProposalStates
    module Overrides
      module ProposalsHelper
        def available_states
          Decidim::CustomProposalStates::ProposalState.where(token: :not_answered, component: current_component) +
            Decidim::CustomProposalStates::ProposalState.answerable.where(component: current_component)
        end

        def proposal_complete_state(proposal)
          return humanize_proposal_state("not_answered").html_safe if proposal.proposal_state.nil?

          translated_attribute(proposal&.proposal_state&.title)
        end

        def proposal_state_css_class(proposal)
          return if proposal.state.blank?
          return ["text", proposal.proposal_state&.css_class].join("-") unless proposal.emendation?

          case proposal.state
          when "accepted"
            "text-success"
          when "rejected", "withdrawn"
            "text-alert"
          when "evaluating"
            "text-warning"
          else
            "text-info"
          end
        end

        def filter_proposals_state_values
          Decidim::CheckBoxesTreeHelper::TreeNode.new(
            Decidim::CheckBoxesTreeHelper::TreePoint.new("", t("decidim.proposals.application_helper.filter_state_values.all")),
            Decidim::CheckBoxesTreeHelper::TreePoint.new("state_not_published", t("decidim.proposals.application_helper.filter_state_values.not_answered")),
            Decidim::CustomProposalStates::ProposalState.where(component: current_component).where.not(token: :not_answered).collect do |state|
              Decidim::CheckBoxesTreeHelper::TreePoint.new(state.token, translated_attribute(state.title))
            end
          )
        end

        def proposal_reason_callout_announcement
          {
            title: translated_attribute(@proposal.proposal_state&.announcement_title),
            body: decidim_sanitize_editor_admin(translated_attribute(@proposal.answer))
          }
        end

        def proposal_reason_callout_class
          if @proposal.emendation?
            case @proposal.state
            when "accepted"
              "success"
            when "evaluating"
              "warning"
            when "rejected"
              "alert"
            else
              ""
            end
          else
            @proposal.proposal_state&.css_class
          end
        end
      end
    end
  end
end
