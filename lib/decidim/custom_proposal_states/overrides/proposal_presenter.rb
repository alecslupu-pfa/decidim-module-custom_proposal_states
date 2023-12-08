# frozen_string_literal: true

module Decidim
  module CustomProposalStates
    module Overrides
      module ProposalPresenter
        def self.prepended(base)
          base.class_eval do
            def versions
              version_state_published = false
              pending_state_change = nil

              proposal.versions.map do |version|
                state_published_change = version.changeset["state_published_at"]
                version_state_published = state_published_change.last.present? if state_published_change

                if version_state_published
                  version.changeset["decidim_proposals_proposal_state_id"] = pending_state_change if pending_state_change
                  pending_state_change = nil
                elsif version.changeset["decidim_proposals_proposal_state_id"]
                  pending_state_change = version.changeset.delete("decidim_proposals_proposal_state_id")
                end

                next if version.event == "update" && Decidim::Proposals::DiffRenderer.new(version).diff.empty?

                version
              end.compact
            end

            def parsed_state_change(old_state, new_state)
              [
                translated_attribute(Decidim::CustomProposalStates::ProposalState.find_by(id: old_state)&.title),
                translated_attribute(Decidim::CustomProposalStates::ProposalState.find_by(id: new_state)&.title)
              ]
            end
          end
        end
      end
    end
  end
end
