# frozen_string_literal: true

require "spec_helper"

describe "Report Proposal", type: :system do
  include_context "with a component" do
    let!(:component) { create(:extended_proposal_component, participatory_space: participatory_process) }
  end

  let(:manifest_name) { "proposals" }
  let!(:proposals) { create_list(:extended_proposal, 3, component: component) }
  let(:reportable) { proposals.first }
  let(:reportable_path) { resource_locator(reportable).path }
  let!(:user) { create :user, :confirmed, organization: organization }

  let!(:component) do
    create(:extended_proposal_component,
           manifest: manifest,
           participatory_space: participatory_process)
  end

  include_examples "reports"
end
