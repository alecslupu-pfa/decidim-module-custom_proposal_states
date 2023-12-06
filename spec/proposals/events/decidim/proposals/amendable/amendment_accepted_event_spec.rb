# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe AmendmentAcceptedEvent do
      let!(:component) { create(:extended_proposal_component) }
      let!(:amendable) { create(:extended_proposal, component: component, title: amendable_title) }
      let!(:emendation) { create(:extended_proposal, component: component, title: "My super emendation") }
      let!(:amendment) { create :amendment, amendable: amendable, emendation: emendation }
      let(:amendable_title) { "My super proposal" }

      include_examples "amendment accepted event"
    end
  end
end
