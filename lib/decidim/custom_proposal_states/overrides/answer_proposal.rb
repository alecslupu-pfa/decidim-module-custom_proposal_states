# frozen_string_literal: true

module Decidim
  module CustomProposalStates
    module Overrides
      module AnswerProposal
        def self.prepended(base)
          base.class_eval do
            def answer_proposal
              Decidim.traceability.perform_action!(
                "answer",
                proposal,
                form.current_user
              ) do
                attributes = {
                  # state: form.state,
                  answer: form.answer,
                  cost: form.cost,
                  cost_report: form.cost_report,
                  execution_period: form.execution_period
                }

                proposal.assign_state(form.state)
                if form.state == "not_answered"
                  attributes[:answered_at] = nil
                  attributes[:state_published_at] = nil
                else
                  attributes[:answered_at] = Time.current
                  attributes[:state_published_at] = Time.current if !initial_has_state_published && form.publish_answer?
                end

                proposal.update!(attributes)
              end
            end

            def store_initial_proposal_state
              @initial_has_state_published = proposal.published_state?
              @initial_state = proposal.proposal_state
            end
          end
        end
      end
    end
  end
end
