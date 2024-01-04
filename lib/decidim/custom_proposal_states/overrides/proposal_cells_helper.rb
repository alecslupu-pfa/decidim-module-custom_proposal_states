# frozen_string_literal: true

module Decidim
  module CustomProposalStates
    module Overrides
      module ProposalCellsHelper
        def badge_name
          if model.emendation?
            humanize_proposal_state state
          else
            translated_attribute(model.proposal_state&.title)
          end
        end

        def state_classes
          return ["muted"] if model.state.blank?
          return ["alert"] if model.withdrawn?
          return model.proposal_state.css_class unless model.emendation?

          case state
          when "accepted"
            ["success"]
          when "rejected"
            ["alert"]
          when "evaluating"
            ["warning"]
          when "withdrawn"
            ["alert"]
          else
            ["muted"]
          end

        end
      end
    end
  end
end
