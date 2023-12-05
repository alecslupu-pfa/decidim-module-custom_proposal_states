# frozen_string_literal: true

require "spec_helper"
require "decidim/proposals/test/capybara_proposals_picker"

describe "Admin manages projects", type: :system do
  let(:manifest_name) { "budgets" }
  let(:budget) { create :budget, component: current_component }
  let!(:project) { create :project, budget: budget }

  include_context "when managing a component as an admin"

  before do
    budget
    switch_to_host(organization.host)
    login_as user, scope: :user
    visit_component_admin

    within find("tr", text: translated(budget.title)) do
      page.find(".action-icon--edit-projects").click
    end
  end

  context "when importing proposals to projects" do
    let!(:proposals) { create_list :extended_proposal, 3, :accepted, component: origin_component }
    let!(:rejected_proposals) { create_list :extended_proposal, 3, :rejected, component: origin_component }
    let!(:origin_component) { create :extended_proposal_component, participatory_space: current_component.participatory_space }
    let!(:default_budget) { 2333 }

    include Decidim::ComponentPathHelper

    it "imports proposals from one component to a budget component" do
      click_link "Import proposals to projects"

      within ".import_proposals" do
        select origin_component.name["en"], from: :proposals_import_origin_component_id
        fill_in "Default budget", with: default_budget
        check :proposals_import_import_all_accepted_proposals
      end

      click_button "Import proposals to projects"

      expect(page).to have_content("3 proposals successfully imported")

      proposals.each do |project|
        expect(page).to have_content(project.title["en"])
      end
    end
  end

  describe "admin form" do
    before do
      within ".process-content" do
        page.find(".button--title.new").click
      end
    end

    it_behaves_like "having a rich text editor", "new_project", "full"

    it "displays the proposals picker" do
      expect(page).to have_content("Choose proposals")
    end

    context "when proposal linking is disabled" do
      before do
        allow(Decidim::Budgets).to receive(:enable_proposal_linking).and_return(false)

        # Reload the page with the updated settings
        visit current_path
      end

      it "does not display the proposal picker" do
        expect(page).not_to have_content "Choose proposals"
      end
    end
  end

  it "updates a project" do
    within find("tr", text: translated(project.title)) do
      click_link "Edit"
    end

    within ".edit_project" do
      fill_in_i18n(
        :project_title,
        "#project-title-tabs",
        en: "My new title",
        es: "Mi nuevo título",
        ca: "El meu nou títol"
      )

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "table" do
      expect(page).to have_content("My new title")
    end
  end

  context "when previewing projects" do
    it "allows the user to preview the project" do
      within find("tr", text: translated(project.title)) do
        klass = "action-icon--preview"
        href = resource_locator([project.budget, project]).path
        target = "blank"

        expect(page).to have_selector(
          :xpath,
          "//a[contains(@class,'#{klass}')][@href='#{href}'][@target='#{target}']"
        )
      end
    end
  end

  context "when seeing finished and pending votes" do
    let!(:project) { create(:project, budget_amount: 70_000_000, budget: budget) }

    let!(:finished_orders) do
      orders = create_list(:order, 10, budget: budget)
      orders.each do |order|
        order.update!(line_items: [create(:line_item, project: project, order: order)])
        order.reload
        order.update!(checked_out_at: Time.zone.today)
      end
    end

    let!(:pending_orders) do
      create_list(:order, 5, budget: budget, checked_out_at: nil)
    end

    it "shows the order count" do
      visit current_path
      expect(page).to have_content("Finished votes: \n10")
      expect(page).to have_content("Pending votes: \n5")
    end
  end

  it "creates a new project", :slow do
    find(".card-title a.button.new").click

    within ".new_project" do
      fill_in_i18n(
        :project_title,
        "#project-title-tabs",
        en: "My project",
        es: "Mi proyecto",
        ca: "El meu projecte"
      )
      fill_in_i18n_editor(
        :project_description,
        "#project-description-tabs",
        en: "A longer description",
        es: "Descripción más larga",
        ca: "Descripció més llarga"
      )
      fill_in :project_budget_amount, with: 22_000_000

      scope_pick select_data_picker(:project_decidim_scope_id), scope
      select translated(category.name), from: :project_decidim_category_id

      find("*[type=submit]").click
    end

    expect(page).to have_admin_callout("successfully")

    within "table" do
      expect(page).to have_content("My project")
    end
  end

  context "when deleting a project" do
    let!(:project2) { create(:project, budget: budget) }

    before do
      visit current_path
    end

    it "deletes a project" do
      within find("tr", text: translated(project2.title)) do
        accept_confirm { click_link "Delete" }
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_no_content(translated(project2.title))
      end
    end
  end

  context "when having existing proposals" do
    let!(:proposal_component) { create(:extended_proposal_component, participatory_space: participatory_space) }
    let!(:proposals) { create_list :extended_proposal, 5, component: proposal_component, skip_injection: true }

    it "updates a project" do
      within find("tr", text: translated(project.title)) do
        click_link "Edit"
      end

      within ".edit_project" do
        fill_in_i18n(
          :project_title,
          "#project-title-tabs",
          en: "My new title",
          es: "Mi nuevo título",
          ca: "El meu nou títol"
        )

        proposals_pick(select_data_picker(:project_proposals, multiple: true), proposals.last(2))

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content("My new title")
      end
    end

    it "removes proposals from project", :slow do
      project.link_resources(proposals, "included_proposals")
      not_removed_projects_title = project.linked_resources(:proposals, "included_proposals").first.title
      expect(project.linked_resources(:proposals, "included_proposals").count).to eq(5)

      within find("tr", text: translated(project.title)) do
        click_link "Edit"
      end

      within ".edit_project" do
        proposals_remove(select_data_picker(:project_proposals, multiple: true), proposals.last(4))

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")
      expect(project.linked_resources(:proposals, "included_proposals").count).to eq(1)
      expect(project.linked_resources(:proposals, "included_proposals").first.title).to eq(not_removed_projects_title)
    end

    it "creates a new project", :slow do
      find(".card-title a.button.new").click

      within ".new_project" do
        fill_in_i18n(
          :project_title,
          "#project-title-tabs",
          en: "My project",
          es: "Mi project",
          ca: "El meu project"
        )
        fill_in_i18n_editor(
          :project_description,
          "#project-description-tabs",
          en: "A longer description",
          es: "Descripción más larga",
          ca: "Descripció més llarga"
        )
        fill_in :project_budget_amount, with: 22_000_000

        proposals_pick(select_data_picker(:project_proposals, multiple: true), proposals.first(2))
        scope_pick(select_data_picker(:project_decidim_scope_id), scope)
        select translated(category.name), from: :project_decidim_category_id

        find("*[type=submit]").click
      end

      expect(page).to have_admin_callout("successfully")

      within "table" do
        expect(page).to have_content("My project")
      end
    end
  end
end
