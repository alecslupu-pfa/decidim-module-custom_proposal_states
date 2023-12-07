# frozen_string_literal: true

require "spec_helper"

describe "Import proposal answers", type: :system do
  let(:organization) { create(:organization, available_locales: [:en, :ca, :es]) }
  let(:component) { create(:extended_proposal_component, organization: organization) }
  let(:proposals) { create_list(:extended_proposal, amount, component: component) }

  let(:manifest_name) { "proposals" }
  let(:participatory_space) { component.participatory_space }
  let(:user) { create :user, organization: organization }

  let(:answers) do
    proposals.map do |proposal|
      {
        id: proposal.id,
        state: %w(accepted rejected evaluating).sample,
        "answer/en": Faker::Lorem.sentence,
        "answer/ca": Faker::Lorem.sentence,
        "answer/es": Faker::Lorem.sentence
      }
    end
  end

  let(:missing_answers) do
    proposals.map do |proposal|
      {
        id: proposal.id,
        state: %w(accepted rejected evaluating).sample,
        "answer/fi": Faker::Lorem.sentence,
        "hello": "world"
      }
    end
  end

  let(:amount) { rand(1..5) }
  let(:json_file) { Rails.root.join("tmp/import_proposal_answers.json") }

  include_context "when managing a component as an admin" do
    let!(:component) { create(:extended_proposal_component, participatory_space: participatory_process) }
  end

  it_behaves_like "admin manages proposal answer imports"
end
