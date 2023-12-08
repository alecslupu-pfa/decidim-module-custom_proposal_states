# frozen_string_literal: true

module Decidim
  module CustomProposalStates
    module Overrides
      module ProposalAnswersController
        def self.prepended(base)
          base.class_eval do
            def edit
              enforce_permission_to :create, :proposal_answer, proposal: proposal
              @form = form(Decidim::CustomProposalStates::Admin::ProposalAnswerForm).from_model(proposal)
            end

            def update
              enforce_permission_to :create, :proposal_answer, proposal: proposal
              @notes_form = form(Decidim::Proposals::Admin::ProposalNoteForm).instance
              @answer_form = form(Decidim::CustomProposalStates::Admin::ProposalAnswerForm).from_params(params)

              Decidim::Proposals::Admin::AnswerProposal.call(@answer_form, proposal) do
                on(:ok) do
                  flash[:notice] = I18n.t("proposals.answer.success", scope: "decidim.proposals.admin")
                  redirect_to proposals_path
                end

                on(:invalid) do
                  flash.keep[:alert] = I18n.t("proposals.answer.invalid", scope: "decidim.proposals.admin")
                  render template: "decidim/proposals/admin/proposals/show"
                end
              end
            end
          end
        end
      end
    end
  end
end
