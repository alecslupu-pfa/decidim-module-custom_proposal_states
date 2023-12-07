# frozen_string_literal: true

shared_context "when admin manages proposals" do
  let(:manifest_name) { "proposals" }
  let!(:proposal) { create :extended_proposal, component: current_component, skip_injection: true, users: [user] }
  let!(:reportables) { create_list(:extended_proposal, 3, component: current_component, skip_injection: true, users: [user]) }
  let(:participatory_space_path) do
    decidim_admin_participatory_processes.edit_participatory_process_path(participatory_process)
  end

  include_context "when managing a component as an admin" do
    let!(:component) { create(:extended_proposal_component, participatory_space: participatory_process) }
  end
end
