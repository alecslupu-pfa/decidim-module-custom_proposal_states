# frozen_string_literal: true

module Decidim
  module CustomProposalStates
    module Overrides
      module AnnouncementCell
        def self.prepended(base)
          base.class_eval do
            def show
              cell "decidim/announcement", announcement, callout_class: state_classes
            end

            def announcement
              emendation_message + promoted_message
            end

            def state_classes
              return "muted" if model.state.blank?
              return "alert" if model.withdrawn?

              model.proposal_state&.css_class
            end
          end
        end
      end
    end
  end
end
