# frozen_string_literal: true

require "spec_helper"

describe "Fingerprint proposal", type: :system do
  let(:manifest_name) { "proposals" }

  let!(:fingerprintable) do
    create(:extended_proposal, component: component)
  end

  include_context "with a component" do
    let!(:component) { create(:extended_proposal_component, participatory_space: participatory_process) }
  end

  it "shows a fingerprint" do
    visit(resource_locator(fingerprintable).path)
    click_link("Check fingerprint")

    within ".fingerprint-dialog" do
      expect(page).to(have_content(fingerprintable.fingerprint.value))
      expect(page).to(have_content(fingerprintable.fingerprint.source))
    end
  end
end
