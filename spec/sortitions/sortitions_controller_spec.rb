# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Sortitions
    module Admin
      describe SortitionsController, type: :controller do
        routes { Decidim::Sortitions::AdminEngine.routes }

        let(:proposals_component) { create(:extended_proposal_component, organization: component.organization) }

        let(:component) { create(:sortition_component) }
        let(:sortition) { create(:sortition, component: component, decidim_proposals_component: proposals_component) }
        let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }

        before do
          request.env["decidim.current_organization"] = component.organization
          request.env["decidim.current_component"] = component
          sign_in user, scope: :user
        end

        describe "create" do
          let(:decidim_category_id) { nil }
          let(:dice) { ::Faker::Number.between(from: 1, to: 6) }
          let(:target_items) { ::Faker::Number.between(from: 1, to: 10) }
          let(:params) do
            {
              participatory_process_slug: component.participatory_space.slug,
              sortition: {
                decidim_proposals_component_id: decidim_proposals_component_id,
                decidim_category_id: decidim_category_id,
                dice: dice,
                target_items: target_items,
                title: {
                  en: "Title",
                  es: "Título",
                  ca: "Títol"
                },
                witnesses: {
                  en: "Witnesses",
                  es: "Testigos",
                  ca: "Testimonis"
                },
                additional_info: {
                  en: "Additional information",
                  es: "Información adicional",
                  ca: "Informació adicional"
                }
              }
            }
          end

          context "with valid params" do
            let(:proposal_component) { create(:extended_proposal_component, participatory_space: component.participatory_space) }
            let(:decidim_proposals_component_id) { proposal_component.id }

            it "redirects to show newly created sortition" do
              expect(controller).to receive(:redirect_to) do |params|
                expect(params).to eq(action: :show, id: Sortition.last.id)
              end

              post :create, params: params
            end

            it "Sortition author is the current user" do
              expect(controller).to receive(:redirect_to) do |params|
                expect(params).to eq(action: :show, id: Sortition.last.id)
              end

              post :create, params: params
              expect(Sortition.last.author).to eq(user)
            end
          end
        end
      end
    end
  end
end
# frozen_string_literal: true
