# frozen_string_literal: true

require "spec_helper"

describe "Orders", type: :system do
  include_context "with a component"
  let(:manifest_name) { "budgets" }

  let(:organization) { create :organization, available_authorizations: %w(dummy_authorization_handler) }
  let!(:user) { create :user, :confirmed, organization: organization }
  let(:project) { projects.first }

  let!(:component) do
    create(:budgets_component,
           :with_vote_threshold_percent,
           manifest: manifest,
           participatory_space: participatory_process)
  end
  let(:budget) { create :budget, component: component }

  describe "show" do
    let!(:project) { create(:project, budget: budget, budget_amount: 25_000_000) }

    before do
      visit resource_locator([budget, project]).path
    end

    context "with linked proposals" do
      let(:proposal_component) do
        create(:extended_proposal_component, participatory_space: project.component.participatory_space)
      end
      let(:proposals) { create_list(:extended_proposal, 3, component: proposal_component) }

      before do
        project.link_resources(proposals, "included_proposals")
      end

      context "with supports enabled" do
        let(:proposal_component) do
          create(:extended_proposal_component, :with_votes_enabled, participatory_space: project.component.participatory_space)
        end

        let(:proposals) { create_list(:extended_proposal, 1, :with_votes, component: proposal_component) }

        it "shows the amount of supports" do
          visit_budget
          click_link translated(project.title)

          expect(page.find('span[class="card--list__data__number"]')).to have_content("5")
        end
      end

      context "with supports disabled" do
        let(:proposal_component) do
          create(:extended_proposal_component, participatory_space: project.component.participatory_space)
        end

        let(:proposals) { create_list(:extended_proposal, 1, :with_votes, component: proposal_component) }

        it "does not show supports" do
          visit_budget
          click_link translated(project.title)

          expect(page).not_to have_selector('span[class="card--list__data__number"]')
        end
      end
    end
  end

  def visit_budget
    page.visit Decidim::EngineRouter.main_proxy(component).budget_projects_path(budget)
  end
end
