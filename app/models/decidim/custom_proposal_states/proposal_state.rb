# frozen_string_literal: true

module Decidim
  module CustomProposalStates
    class ProposalState < ApplicationRecord
      self.table_name = :decidim_proposals_proposal_states

      include Decidim::HasComponent
      include Decidim::Traceable
      include Decidim::Loggable

      include Decidim::TranslatableResource
      include Decidim::TranslatableAttributes

      translatable_fields :title

      validates :token, presence: true, uniqueness: { scope: :component }

      scope :answerable, -> { where(answerable: true) }
      scope :system, -> { where(system: true) }
      scope :not_system, -> { where(system: false) }
      scope :default, -> { where(default: true) }
      scope :notifiable, -> { where(notifiable: true) }

      translatable_fields :title, :description

      has_many :proposals,
               class_name: "Decidim::Proposals::Proposal",
               foreign_key: "decidim_proposals_proposal_state_id",
               inverse_of: :proposal_state,
               dependent: :restrict_with_error,
               counter_cache: :proposals_count

      def self.log_presenter_class_for(_log)
        Decidim::CustomProposalStates::AdminLog::ProposalStatePresenter
      end
    end
  end
end
