# frozen_string_literal: true

require "spec_helper"

describe Decidim::Proposals::AdminLog::ValuationAssignmentPresenter, type: :helper do
  include_examples "present admin log entry" do
    let(:participatory_space) { create(:participatory_process, organization: organization) }
    let(:component) { create(:extended_proposal_component, participatory_space: participatory_space) }
    let(:proposal) { create(:extended_proposal, component: component) }
    let(:admin_log_resource) { create(:valuation_assignment, proposal: proposal) }
    let(:action) { "delete" }
  end
end
