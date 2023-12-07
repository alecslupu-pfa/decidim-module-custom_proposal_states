# frozen_string_literal: true

require "spec_helper"

describe "Proposal", type: :system do
  let!(:component) { create(:extended_proposal_component, participatory_space: participatory_process) }

  it_behaves_like "proposals wizards", with_address: false
  it_behaves_like "proposals wizards", with_address: true
end
