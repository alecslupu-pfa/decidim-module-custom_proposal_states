# frozen_string_literal: true

module Decidim
  module CustomProposalStates
    module Overrides
      module Proposal
        def self.prepended(base)
          base.class_eval do
            before_create :set_default_state

            belongs_to :proposal_state,
                       class_name: "Decidim::CustomProposalStates::ProposalState",
                       foreign_key: "decidim_proposals_proposal_state_id",
                       inverse_of: :proposals,
                       optional: true,
                       counter_cache: true
            scope :not_status, lambda { |status|
              joins(:proposal_state).where.not(decidim_proposals_proposal_states: { token: status })
                                    .where(%(
                      ("decidim_proposals_proposals"."state_published_at" IS NULL AND  "decidim_proposals_proposal_states"."answerable" = TRUE) OR
                      ("decidim_proposals_proposals"."state_published_at" IS NOT NULL AND  "decidim_proposals_proposal_states"."answerable" = FALSE)
                  ))
            }
            scope :only_status, lambda { |status|
              joins(:proposal_state).where(decidim_proposals_proposal_states: { token: status })
                                    .where(%(
                      ("decidim_proposals_proposals"."state_published_at" IS NOT NULL AND  "decidim_proposals_proposal_states"."answerable" = TRUE) OR
                      ("decidim_proposals_proposals"."state_published_at" IS NULL AND  "decidim_proposals_proposal_states"."answerable" = FALSE)
                  ))
            }

            scope :accepted, -> { state_published.only_status(:accepted) }
            scope :rejected, -> { state_published.only_status(:rejected) }
            scope :evaluating, -> { state_published.only_status(:evaluating) }
            scope :except_withdrawn, -> { joins(:proposal_state).where.not(decidim_proposals_proposal_states: { token: :withdrawn }) }

            scope :gamified, -> { state_published.only_status(:accepted).where(decidim_proposals_proposal_states: { gamified: true }) }

            scope :state_published, -> { where.not(state_published_at: nil) }
            scope :except_rejected, -> { not_status(:rejected).or(state_not_published) }
            scope :withdrawn, -> { joins(:proposal_state).where(decidim_proposals_proposal_states: { token: :withdrawn }) }
            scope :except_withdrawn, -> { joins(:proposal_state).where.not(decidim_proposals_proposal_states: { token: :withdrawn }) }

            def set_default_state
              return if proposal_state.present?

              assign_state("not_answered")
            end

            def assign_state(token)
              proposal_state = Decidim::CustomProposalStates::ProposalState.where(component: component, token: token).first!
              self.proposal_state = proposal_state
            end

            def state
              return amendment.state if emendation?
              return nil unless published_state? || withdrawn?

              proposal_state&.token
            end

            def internal_state
              return amendment.state if emendation?

              proposal_state&.token
            end

            def process_amendment_state_change!
              return unless %w(accepted rejected evaluating withdrawn).member?(amendment.state)

              PaperTrail.request(enabled: false) do
                assign_state(amendment.state)
                update!(state_published_at: Time.current)
              end
            end
          end
        end
      end
    end
  end
end
