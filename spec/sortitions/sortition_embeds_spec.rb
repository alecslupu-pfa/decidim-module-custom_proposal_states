# frozen_string_literal: true

require "spec_helper"

describe "Sortition embeds", type: :system do
  include_context "with a component"
  let(:manifest_name) { "sortitions" }

  let(:target_items) { Faker::Number.between(from: 1, to: 5).to_i }
  let(:proposals_component) { create(:extended_proposal_component, organization: component.organization) }
  let(:selected_proposals) { create_list(:extended_proposal, target_items, component: proposals_component).pluck(:id) }

  let(:resource) { create(:sortition, selected_proposals: selected_proposals, decidim_proposals_component: proposals_component, target_items: target_items, component: component) }

  it_behaves_like "an embed resource"
end
