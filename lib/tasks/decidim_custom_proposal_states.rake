# frozen_string_literal: true

namespace :decidim do
  namespace :custom_proposal_states do
    task :choose_target_plugins do
      ENV["FROM"] = "#{ENV.fetch("FROM", nil)},decidim_custom_proposal_states"
    end
  end
end

Rake::Task["decidim:choose_target_plugins"].enhance do
  Rake::Task["decidim:custom_proposal_states:choose_target_plugins"].invoke
end
