# frozen_string_literal: true

require "rails"
require "deface"
require "decidim/core"
require "decidim/components/namer"

module Decidim
  module CustomProposalStates
    # This is the engine that runs on the public interface of custom_proposal_states.
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::CustomProposalStates

      routes do
        # Add engine routes here
        # resources :custom_proposal_states
        # root to: "custom_proposal_states#index"
      end

      initializer "decidim_custom_proposal_states.views" do
        Rails.application.configure do
          config.deface.enabled = true
        end
      end

      # Subscribes to ActiveSupport::Notifications that may affect a Proposal.
      initializer "decidim_custom_proposal_states.subscribe_to_events" do
        next unless Decidim::CustomProposalStates.module_installed?("accountability")

        Rails.application.reloader.to_prepare do
          # when a proposal is linked from a result
          event_name = "decidim.resourceable.included_proposals.created"

          ActiveSupport::Notifications.unsubscribe event_name

          ActiveSupport::Notifications.subscribe event_name do |_name, _started, _finished, _unique_id, data|
            payload = data[:this]
            if payload[:from_type] == Decidim::Accountability::Result.name && payload[:to_type] == Decidim::Proposals::Proposal.name
              proposal = Decidim::Proposals::Proposal.find(payload[:to_id])
              proposal.assign_state("accepted")
              proposal.update(state_published_at: Time.current)
            end
          end
        end
      end

      initializer "decidim_custom_proposal_states.overrides.budgets" do
        next unless Decidim::CustomProposalStates.module_installed?("budgets")

        Rails.application.reloader.to_prepare do
          Decidim::Budgets::Admin::ImportProposalsToBudgets.prepend Decidim::CustomProposalStates::Overrides::ImportProposalsToBudgets
        end
      end

      initializer "decidim_custom_proposal_states.overrides.elections" do
        next unless Decidim::CustomProposalStates.module_installed?("elections")

        Rails.application.reloader.to_prepare do
          Decidim::Elections::Admin::ImportProposalsToElections.prepend Decidim::CustomProposalStates::Overrides::ImportProposalsToElections
        end
      end

      initializer "decidim_custom_proposal_states.action_controller", after: "decidim.action_controller" do
        config.to_prepare do
          ActiveSupport.on_load :action_controller do
            Decidim::Proposals::ProposalsHelper.module_eval do
              prepend Decidim::CustomProposalStates::Overrides::ProposalsHelper
            end
            Decidim::Proposals::Admin::ProposalsHelper.module_eval do
              prepend Decidim::CustomProposalStates::Overrides::ProposalsHelper
            end
            Decidim::Proposals::ApplicationHelper.module_eval do
              prepend Decidim::CustomProposalStates::Overrides::ProposalsHelper
            end

            Decidim::Proposals::Admin::ApplicationController.prepend Decidim::CustomProposalStates::Overrides::ProposalsHelper
            Decidim::Proposals::Admin::ProposalsController.prepend Decidim::CustomProposalStates::Overrides::AdminFilterable
            Decidim::Proposals::Admin::ProposalAnswersController.prepend Decidim::CustomProposalStates::Overrides::ProposalAnswersController
            Decidim::Proposals::ProposalsController.prepend Decidim::CustomProposalStates::Overrides::ProposalsController
          end
        end
      end

      initializer "decidim_custom_proposal_states.overrides.proposal" do
        Rails.application.reloader.to_prepare do
          Decidim::Amendable::AnnouncementCell.prepend Decidim::CustomProposalStates::Overrides::AnnouncementCell
          Decidim::Proposals::ProposalCellsHelper.prepend Decidim::CustomProposalStates::Overrides::ProposalCellsHelper
          Decidim::Proposals::Proposal.prepend Decidim::CustomProposalStates::Overrides::Proposal
          Decidim::Proposals::WithdrawProposal.prepend Decidim::CustomProposalStates::Overrides::WithdrawProposal
          Decidim::Proposals::Admin::ImportProposals.prepend Decidim::CustomProposalStates::Overrides::ImportProposals
          Decidim::Proposals::Admin::AnswerProposal.prepend Decidim::CustomProposalStates::Overrides::AnswerProposal
          Decidim::Proposals::Admin::NotifyProposalAnswer.prepend Decidim::CustomProposalStates::Overrides::NotifyProposalAnswer
          Decidim::Proposals::Import::ProposalAnswerCreator.prepend Decidim::CustomProposalStates::Overrides::ProposalAnswerCreator
          Decidim::Proposals::ProposalPresenter.prepend Decidim::CustomProposalStates::Overrides::ProposalPresenter
          Decidim::Proposals::DiffRenderer.prepend Decidim::CustomProposalStates::Overrides::DiffRenderer
          Decidim::Proposals::ProposalSearch.prepend Decidim::CustomProposalStates::Overrides::ProposalSearch
        end
      end

      initializer "decidim_custom_proposal_states.patch_engine" do
        next if Decidim::Gamification.find_badge(:accepted_proposals).blank?

        Rails.application.reloader.to_prepare do
          Decidim::Gamification.find_badge(:accepted_proposals).reset = lambda { |model|
            proposal_ids = case model
                           when User
                             Decidim::Coauthorship.where(
                               coauthorable_type: "Decidim::Proposals::Proposal",
                               author: model,
                               user_group: nil
                             ).select(:coauthorable_id)
                           when UserGroup
                             Decidim::Coauthorship.where(
                               coauthorable_type: "Decidim::Proposals::Proposal",
                               user_group: model
                             ).select(:coauthorable_id)
                           end

            Decidim::Proposals::Proposal.where(id: proposal_ids).gamified.count
          }
        end
      end

      initializer "decidim_custom_proposal_states.patch_component" do
        Rails.application.reloader.to_prepare do
          Decidim.find_component_manifest(:proposals).on(:create) do |instance|
            admin_user = GlobalID::Locator.locate(instance.versions.first.whodunnit)
            Decidim::CustomProposalStates.create_default_states!(instance, admin_user)
          end

          Decidim.find_component_manifest(:proposals).seeds do |participatory_space|
            admin_user = Decidim::User.find_by(
              organization: participatory_space.organization,
              email: "admin@example.org"
            )

            step_settings = if participatory_space.allows_steps?
                              { participatory_space.active_step.id => { votes_enabled: true, votes_blocked: false, creation_enabled: true } }
                            else
                              {}
                            end

            params = {
              name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :proposals).i18n_name,
              manifest_name: :proposals,
              published_at: Time.current,
              participatory_space: participatory_space,
              settings: {
                vote_limit: 0,
                collaborative_drafts_enabled: true
              },
              step_settings: step_settings
            }

            component = Decidim.traceability.perform_action!(
              "publish",
              Decidim::Component,
              admin_user,
              visibility: "all"
            ) do
              Decidim::Component.create!(params)
            end

            Decidim::CustomProposalStates.create_default_states!(component, admin_user)

            if participatory_space.scope
              scopes = participatory_space.scope.descendants
              global = participatory_space.scope
            else
              scopes = participatory_space.organization.scopes
              global = nil
            end

            5.times do |n|
              state, answer, state_published_at = if n > 3
                                                    ["accepted", Decidim::Faker::Localized.sentence(word_count: 10), Time.current]
                                                  elsif n > 2
                                                    ["rejected", nil, Time.current]
                                                  elsif n > 1
                                                    ["evaluating", nil, Time.current]
                                                  elsif n.positive?
                                                    ["accepted", Decidim::Faker::Localized.sentence(word_count: 10), nil]
                                                  else
                                                    ["not_answered", nil, nil]
                                                  end
              proposal_state = Decidim::CustomProposalStates::ProposalState.where(component: component, token: state).first!

              params = {
                component: component,
                category: participatory_space.categories.sample,
                scope: ::Faker::Boolean.boolean(true_ratio: 0.5) ? global : scopes.sample,
                title: { en: ::Faker::Lorem.sentence(word_count: 2) },
                body: { en: ::Faker::Lorem.paragraphs(number: 2).join("\n") },
                proposal_state: proposal_state,
                answer: answer,
                answered_at: proposal_state.present? ? Time.current : nil,
                state_published_at: state_published_at,
                published_at: Time.current
              }

              proposal = Decidim.traceability.perform_action!(
                "publish",
                Decidim::Proposals::Proposal,
                admin_user,
                visibility: "all"
              ) do
                proposal = Decidim::Proposals::Proposal.new(params)
                proposal.add_coauthor(participatory_space.organization)
                proposal.save!
                proposal
              end

              if n.positive?
                Decidim::User.where(decidim_organization_id: participatory_space.decidim_organization_id).all.sample(n).each do |author|
                  user_group = [true, false].sample ? Decidim::UserGroups::ManageableUserGroups.for(author).verified.sample : nil
                  proposal.add_coauthor(author, user_group: user_group)
                end
              end

              if proposal.state.nil?
                email = "amendment-author-#{participatory_space.underscored_name}-#{participatory_space.id}-#{n}-amend#{n}@example.org"
                name = "#{::Faker::Name.name} #{participatory_space.id} #{n} amend#{n}"

                author = Decidim::User.find_or_initialize_by(email: email)
                author.update!(
                  password: "decidim123456",
                  password_confirmation: "decidim123456",
                  name: name,
                  nickname: ::Faker::Twitter.unique.screen_name,
                  organization: component.organization,
                  tos_agreement: "1",
                  confirmed_at: Time.current
                )

                group = Decidim::UserGroup.create!(
                  name: ::Faker::Name.name,
                  nickname: ::Faker::Twitter.unique.screen_name,
                  email: ::Faker::Internet.email,
                  extended_data: {
                    document_number: ::Faker::Code.isbn,
                    phone: ::Faker::PhoneNumber.phone_number,
                    verified_at: Time.current
                  },
                  decidim_organization_id: component.organization.id,
                  confirmed_at: Time.current
                )

                Decidim::UserGroupMembership.create!(
                  user: author,
                  role: "creator",
                  user_group: group
                )

                params = {
                  component: component,
                  category: participatory_space.categories.sample,
                  scope: ::Faker::Boolean.boolean(true_ratio: 0.5) ? global : scopes.sample,
                  title: { en: "#{proposal.title["en"]} #{::Faker::Lorem.sentence(word_count: 1)}" },
                  body: { en: "#{proposal.body["en"]} #{::Faker::Lorem.sentence(word_count: 3)}" },
                  proposal_state: Decidim::CustomProposalStates::ProposalState.where(component: proposal.component, token: :evaluating).first!,
                  answer: nil,
                  answered_at: Time.current,
                  published_at: Time.current
                }

                emendation = Decidim.traceability.perform_action!(
                  "create",
                  Decidim::Proposals::Proposal,
                  author,
                  visibility: "public-only"
                ) do
                  emendation = Decidim::Proposals::Proposal.new(params)
                  emendation.add_coauthor(author, user_group: author.user_groups.first)
                  emendation.save!
                  emendation
                end

                Decidim::Amendment.create!(
                  amender: author,
                  amendable: proposal,
                  emendation: emendation,
                  state: "evaluating"
                )
              end

              (n % 3).times do |m|
                email = "vote-author-#{participatory_space.underscored_name}-#{participatory_space.id}-#{n}-#{m}@example.org"
                name = "#{::Faker::Name.name} #{participatory_space.id} #{n} #{m}"

                author = Decidim::User.find_or_initialize_by(email: email)
                author.update!(
                  password: "decidim123456",
                  password_confirmation: "decidim123456",
                  name: name,
                  nickname: ::Faker::Twitter.unique.screen_name,
                  organization: component.organization,
                  tos_agreement: "1",
                  confirmed_at: Time.current,
                  personal_url: ::Faker::Internet.url,
                  about: ::Faker::Lorem.paragraph(sentence_count: 2)
                )

                Decidim::Proposals::ProposalVote.create!(proposal: proposal, author: author) unless proposal.published_state? && proposal.rejected?
                Decidim::Proposals::ProposalVote.create!(proposal: emendation, author: author) if emendation
              end

              unless proposal.published_state? && proposal.rejected?
                (n * 2).times do |index|
                  email = "endorsement-author-#{participatory_space.underscored_name}-#{participatory_space.id}-#{n}-endr#{index}@example.org"
                  name = "#{::Faker::Name.name} #{participatory_space.id} #{n} endr#{index}"

                  author = Decidim::User.find_or_initialize_by(email: email)
                  author.update!(
                    password: "decidim123456",
                    password_confirmation: "decidim123456",
                    name: name,
                    nickname: ::Faker::Twitter.unique.screen_name,
                    organization: component.organization,
                    tos_agreement: "1",
                    confirmed_at: Time.current
                  )
                  if index.even?
                    group = Decidim::UserGroup.create!(
                      name: ::Faker::Name.name,
                      nickname: ::Faker::Twitter.unique.screen_name,
                      email: ::Faker::Internet.email,
                      extended_data: {
                        document_number: ::Faker::Code.isbn,
                        phone: ::Faker::PhoneNumber.phone_number,
                        verified_at: Time.current
                      },
                      decidim_organization_id: component.organization.id,
                      confirmed_at: Time.current
                    )

                    Decidim::UserGroupMembership.create!(
                      user: author,
                      role: "creator",
                      user_group: group
                    )
                  end
                  Decidim::Endorsement.create!(resource: proposal, author: author, user_group: author.user_groups.first)
                end
              end

              (n % 3).times do
                author_admin = Decidim::User.where(organization: component.organization, admin: true).all.sample

                Decidim::Proposals::ProposalNote.create!(
                  proposal: proposal,
                  author: author_admin,
                  body: ::Faker::Lorem.paragraphs(number: 2).join("\n")
                )
              end

              Decidim::Comments::Seed.comments_for(proposal)

              #
              # Collaborative drafts
              #
              state = if n > 3
                        "published"
                      elsif n > 2
                        "withdrawn"
                      else
                        "open"
                      end
              author = Decidim::User.where(organization: component.organization).all.sample

              draft = Decidim.traceability.perform_action!("create", Decidim::Proposals::CollaborativeDraft, author) do
                draft = Decidim::Proposals::CollaborativeDraft.new(
                  component: component,
                  category: participatory_space.categories.sample,
                  scope: ::Faker::Boolean.boolean(true_ratio: 0.5) ? global : scopes.sample,
                  title: ::Faker::Lorem.sentence(word_count: 2),
                  body: ::Faker::Lorem.paragraphs(number: 2).join("\n"),
                  state: state,
                  published_at: Time.current
                )
                draft.coauthorships.build(author: participatory_space.organization)
                draft.save!
                draft
              end

              case n
              when 2
                author2 = Decidim::User.where(organization: component.organization).all.sample
                Decidim::Coauthorship.create(coauthorable: draft, author: author2)
                author3 = Decidim::User.where(organization: component.organization).all.sample
                Decidim::Coauthorship.create(coauthorable: draft, author: author3)
                author4 = Decidim::User.where(organization: component.organization).all.sample
                Decidim::Coauthorship.create(coauthorable: draft, author: author4)
                author5 = Decidim::User.where(organization: component.organization).all.sample
                Decidim::Coauthorship.create(coauthorable: draft, author: author5)
                author6 = Decidim::User.where(organization: component.organization).all.sample
                Decidim::Coauthorship.create(coauthorable: draft, author: author6)
              when 3
                author2 = Decidim::User.where(organization: component.organization).all.sample
                Decidim::Coauthorship.create(coauthorable: draft, author: author2)
              end

              Decidim::Comments::Seed.comments_for(draft)
            end

            Decidim.traceability.update!(
              Decidim::Proposals::CollaborativeDraft.all.sample,
              Decidim::User.where(organization: component.organization).all.sample,
              component: component,
              category: participatory_space.categories.sample,
              scope: ::Faker::Boolean.boolean(true_ratio: 0.5) ? global : scopes.sample,
              title: ::Faker::Lorem.sentence(word_count: 2),
              body: ::Faker::Lorem.paragraphs(number: 2).join("\n")
            )
          end
        end
      end
    end
  end
end
