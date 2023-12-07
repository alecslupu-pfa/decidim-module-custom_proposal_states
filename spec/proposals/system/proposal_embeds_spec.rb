# frozen_string_literal: true

require "spec_helper"

describe "Proposal embeds", type: :system do
  include_context "with a component" do
    let!(:component) { create(:extended_proposal_component, participatory_space: participatory_process) }
  end
  let(:manifest_name) { "proposals" }
  let(:resource) { create(:extended_proposal, component: component) }

  it_behaves_like "an embed resource"
end
