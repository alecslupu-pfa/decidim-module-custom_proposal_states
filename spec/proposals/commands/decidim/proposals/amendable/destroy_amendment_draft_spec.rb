# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe DestroyDraft do
      let!(:component) { create(:extended_proposal_component) }
      let!(:other_user) { create(:user, :confirmed, organization: component.organization) }

      let!(:amendable) { create(:extended_proposal, component: component) }
      let!(:emendation) { create(:extended_proposal, :unpublished, component: component) }
      let!(:amendment) { create(:amendment, :draft, amendable: amendable, emendation: emendation) }

      let(:command) { described_class.new(amendment, current_user) }

      include_examples "destroy amendment draft"
    end
  end
end
