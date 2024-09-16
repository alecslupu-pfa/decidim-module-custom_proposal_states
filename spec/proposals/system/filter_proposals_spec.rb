# frozen_string_literal: true

require "spec_helper"

describe "Filter Proposals", :slow, type: :system do
  include_context "with a component" do
    let!(:component) { create(:extended_proposal_component, participatory_space: participatory_process) }
  end
  let(:manifest_name) { "proposals" }

  let!(:category) { create :category, participatory_space: participatory_process }
  let!(:scope) { create :scope, organization: organization }
  let!(:user) { create :user, :confirmed, organization: organization }
  let(:scoped_participatory_process) { create(:participatory_process, :with_steps, organization: organization, scope: scope) }

  context "when filtering proposals by STATE" do
    context "when proposal_answering component setting is enabled" do
      let!(:custom_state) { create(:proposal_state, answerable: true, system: false, component: component, token: :custom_state, title: { "en" => "Custom state" }) }

      before do
        component.update!(settings: { proposal_answering_enabled: true })
      end

      context "when proposal_answering step setting is enabled" do
        before do
          component.update!(
            step_settings: {
              component.participatory_space.active_step.id => {
                proposal_answering_enabled: true
              }
            }
          )
        end

        it "can be filtered by state" do
          visit_component

          within "form.new_filter" do
            expect(page).to have_content(/Status/i)

            expect(page).to have_content(/Accepted/i)
            expect(page).to have_content(/Evaluating/i)
            expect(page).to have_content(/Rejected/i)
            expect(page).to have_content(/Not answered/i)
            expect(page).to have_content(/Custom state/i)
          end
        end

        it "lists custom proposals" do
          create(:extended_proposal, :custom_state, answered_at: Time.current, state_published_at: Time.current,
                                                    component: component, scope: scope)
          visit_component

          within ".filters .with_any_state_check_boxes_tree_filter" do
            check "All"
            uncheck "All"
            check "Custom state"
          end

          expect(page).to have_css(".card--proposal", count: 1)
          expect(page).to have_content("1 PROPOSAL")

          within ".card--proposal" do
            expect(page).to have_content("Custom state".upcase)
          end
        end

        it "lists accepted proposals" do
          create(:extended_proposal, :accepted, component: component, scope: scope)
          visit_component

          within ".filters .with_any_state_check_boxes_tree_filter" do
            check "All"
            uncheck "All"
            check "Accepted"
          end

          expect(page).to have_css(".card--proposal", count: 1)
          expect(page).to have_content("1 PROPOSAL")

          within ".card--proposal" do
            expect(page).to have_content("ACCEPTED")
          end
        end

        it "lists the filtered proposals" do
          create(:extended_proposal, :rejected, component: component, scope: scope)
          visit_component

          within ".filters .with_any_state_check_boxes_tree_filter" do
            check "All"
            uncheck "All"
            check "Rejected"
          end

          expect(page).to have_css(".card--proposal", count: 1)
          expect(page).to have_content("1 PROPOSAL")

          within ".card--proposal" do
            expect(page).to have_content("REJECTED")
          end
        end

        context "when there are proposals with answers not published" do
          let!(:proposal) { create(:extended_proposal, :accepted_not_published, component: component, scope: scope) }

          before do
            create(:extended_proposal, :accepted, component: component, scope: scope)

            visit_component
          end

          it "shows only accepted proposals with published answers" do
            within ".filters .with_any_state_check_boxes_tree_filter" do
              check "All"
              uncheck "All"
              check "Accepted"
            end

            expect(page).to have_css(".card--proposal", count: 1)
            expect(page).to have_content("1 PROPOSAL")

            within ".card--proposal" do
              expect(page).to have_content("ACCEPTED")
            end
          end

          it "shows accepted proposals with not published answers as not answered" do
            within ".filters .with_any_state_check_boxes_tree_filter" do
              check "All"
              uncheck "All"
              check "Not answered"
            end

            expect(page).to have_css(".card--proposal", count: 1)
            expect(page).to have_content("1 PROPOSAL")

            within ".card--proposal" do
              expect(page).to have_content(translated(proposal.title))
              expect(page).not_to have_content("ACCEPTED")
            end
          end
        end
      end

      context "when proposal_answering step setting is disabled" do
        before do
          component.update!(
            step_settings: {
              component.participatory_space.active_step.id => {
                proposal_answering_enabled: false
              }
            }
          )
        end

        it "cannot be filtered by state" do
          visit_component

          within "form.new_filter" do
            expect(page).to have_no_content(/Status/i)
          end
        end
      end
    end

    context "when proposal_answering component setting is not enabled" do
      before do
        component.update!(settings: { proposal_answering_enabled: false })
      end

      it "cannot be filtered by state" do
        visit_component

        within "form.new_filter" do
          expect(page).to have_no_content(/Status/i)
        end
      end
    end
  end
end
