# frozen_string_literal: true

require "decidim/core/test/factories"

def generate_state_title(token)
  Decidim::Faker::Localized.localized { I18n.t(token, scope: "decidim.proposals.answers") }
end

FactoryBot.define do
  factory :extended_proposal_component, parent: :proposal_component do
    name { { "en" => "Foo bar" } }

    after :create do |proposal_component|
      Decidim::CustomProposalStates.create_default_states!(proposal_component, nil, with_traceability: false)
    end
  end

  factory :extended_proposal, parent: :proposal do
    transient do
      state { :not_answered }
    end
    component { build(:extended_proposal_component) }

    after(:build) do |proposal, evaluator|
      if proposal.component
        existing_states = Decidim::CustomProposalStates::ProposalState.where(component: proposal.component)

        Decidim::CustomProposalStates.create_default_states!(proposal.component, nil, with_traceability: false) unless existing_states.any?
      end

      proposal_state = Decidim::CustomProposalStates::ProposalState.where(component: proposal.component, token: evaluator.state).first!
      proposal.proposal_state = proposal_state
    end

    trait :not_answered do
      state { :not_answered }
      answered_at { nil }
    end

    trait :evaluating do
      state { :evaluating }
      answered_at { Time.current }
      state_published_at { Time.current }
    end

    trait :accepted do
      state { :accepted }
      answered_at { Time.current }
      state_published_at { Time.current }
    end

    trait :rejected do
      state { :rejected }
      answered_at { Time.current }
      state_published_at { Time.current }
    end

    trait :withdrawn do
      state { :withdrawn }
    end

    trait :custom_state do
      state { :custom_state }
    end

    trait :with_answer do
      state { :accepted }
      answer { generate_localized_title }
      answered_at { Time.current }
      state_published_at { Time.current }
    end

    trait :accepted_not_published do
      state { :accepted }
      answered_at { Time.current }
      state_published_at { nil }
      answer { generate_localized_title }
    end
  end

  factory :proposal_state, class: "Decidim::CustomProposalStates::ProposalState" do
    token { :not_answered }
    title { generate_state_title(:not_answered) }
    description { Decidim::Faker::Localized.localized { Faker::Lorem.sentences(number: 3).join("\n") } }
    component { build(:proposal_component) }
    default { false }
    gamified { false }
    system { true }
    css_class { "" }

    trait :evaluating do
      title { generate_state_title(:evaluating) }
      token { :evaluating }
      system { true }
      notifiable { true }
      answerable { true }
    end

    trait :accepted do
      title { generate_state_title(:accepted) }
      token { :accepted }
      system { true }
      gamified { true }
      notifiable { true }
      answerable { true }
    end

    trait :rejected do
      title { generate_state_title(:rejected) }
      token { :rejected }
      system { true }
      notifiable { true }
      answerable { true }
    end

    trait :withdrawn do
      title { generate_state_title(:withdrawn) }
      token { :withdrawn }
      system { true }
    end
  end
end
