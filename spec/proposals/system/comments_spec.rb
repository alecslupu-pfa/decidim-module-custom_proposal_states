# frozen_string_literal: true

require "spec_helper"

describe "Comments", type: :system do
  let!(:component) { create(:extended_proposal_component, organization: organization) }
  let!(:author) { create(:user, :confirmed, organization: organization) }
  let!(:commentable) { create(:extended_proposal, component: component, users: [author]) }
  let!(:organization) { create(:organization) }
  let!(:user) { create(:user, :confirmed, organization: organization) }
  let!(:comments) { create_list(:comment, 3, commentable: commentable) }

  let(:resource_path) { resource_locator(commentable).path }

  after do
    expect_no_js_errors
  end

  before do
    switch_to_host(organization.host)
  end

  include_examples "comments"
end
