# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Amendable
    describe ReviewForm do
      subject { form }

      let(:component) { create(:extended_proposal_component) }
      let(:amendable) { create(:extended_proposal, component: component) }
      let(:emendation) { create(:extended_proposal, component: component) }
      let(:amendment) { create(:amendment, amendable: amendable, emendation: emendation) }

      let(:form) do
        described_class.from_params(form_params).with_context(form_context)
      end

      let(:form_params) do
        {
          id: amendment.id,
          emendation_params: emendation_params
        }
      end

      let(:form_context) do
        {
          current_user: amendable.creator_author,
          current_organization: amendable.organization,
          current_participatory_space: amendable.participatory_space,
          current_component: amendable.component
        }
      end

      it_behaves_like "an amendment form"
    end
  end
end
