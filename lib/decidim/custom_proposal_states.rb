# frozen_string_literal: true

require "decidim/custom_proposal_states/admin"
require "decidim/custom_proposal_states/engine"
require "decidim/custom_proposal_states/admin_engine"

module Decidim
  # This namespace holds the logic of the `CustomProposalStates` component. This component
  # allows users to create custom_proposal_states in a participatory space.
  module CustomProposalStates
    module Overrides
      autoload :Proposal, "decidim/custom_proposal_states/overrides/proposal"
    end

    def self.create_default_states!(component, admin_user, with_traceability: true)
      locale = Decidim.default_locale
      default_states = {
        not_answered: {
          token: :not_answered,
          css_class: "info",
          default: true,
          include_in_stats: {},
          system: true,
          answerable: false,
          notifiable: false,
          title: { locale => I18n.with_locale(locale) { I18n.t(:not_answered, scope: "decidim.proposals.answers") } }
        },
        evaluating: {
          token: :evaluating,
          css_class: "warning",
          default: false,
          include_in_stats: {},
          answerable: true,
          system: true,
          notifiable: true,
          announcement_title: { locale => I18n.with_locale(locale) { I18n.t("proposal_in_evaluation_reason", scope: "decidim.proposals.proposals.show") } },
          title: { locale => I18n.with_locale(locale) { I18n.t(:evaluating, scope: "decidim.proposals.answers") } }
        },
        accepted: {
          token: :accepted,
          css_class: "success",
          default: false,
          include_in_stats: {},
          answerable: true,
          notifiable: true,
          system: true,
          gamified: true,
          announcement_title: { locale => I18n.with_locale(locale) { I18n.t("proposal_accepted_reason", scope: "decidim.proposals.proposals.show") } },
          title: { locale => I18n.with_locale(locale) { I18n.t(:accepted, scope: "decidim.proposals.answers") } }
        },
        rejected: {
          token: :rejected,
          css_class: "alert",
          default: false,
          include_in_stats: {},
          answerable: true,
          notifiable: true,
          system: true,
          announcement_title: { locale => I18n.with_locale(locale) { I18n.t("proposal_rejected_reason", scope: "decidim.proposals.proposals.show") } },
          title: { locale => I18n.with_locale(locale) { I18n.t(:rejected, scope: "decidim.proposals.answers") } }
        },
        withdrawn: {
          token: :withdrawn,
          css_class: "alert",
          default: false,
          include_in_stats: {},
          system: true,
          answerable: false,
          notifiable: false,
          title: { locale => I18n.with_locale(locale) { I18n.t(:withdrawn, scope: "decidim.proposals.answers") } }
        }
      }
      default_states.each_key do |key|
        default_states[key][:object] = if with_traceability
                                         Decidim.traceability.create(
                                           Decidim::CustomProposalStates::ProposalState, admin_user, component: component, **default_states[key]
                                         )
                                       else
                                         Decidim::CustomProposalStates::ProposalState.create(component: component, **default_states[key])
                                       end
      end
      default_states
    end
  end
end
