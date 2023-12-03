# frozen_string_literal: true

$LOAD_PATH.push File.expand_path("lib", __dir__)

require "decidim/custom_proposal_states/version"

Gem::Specification.new do |s|
  s.version = Decidim::CustomProposalStates.version
  s.authors = ["Alexandru Emil Lupu"]
  s.email = ["contact@alecslupu.ro"]
  s.license = "AGPL-3.0"
  s.homepage = "https://github.com/alecslupu-pfa/decidim-module-custom_proposal_states"
  s.required_ruby_version = ">= 2.7"

  s.name = "decidim-custom_proposal_states"
  s.summary = "A decidim custom_proposal_states module"
  s.description = "This module allows you to customize the proposal states."

  s.files = Dir["{app,config,lib}/**/*", "LICENSE-AGPLv3.txt", "Rakefile", "README.md"]

  s.add_dependency "decidim-core", ">= 0.26.0", "< 0.28.0"
  s.add_dependency "decidim-proposals", ">= 0.26.0", "< 0.28.0"
  s.add_dependency "deface", ">= 1.9"
  s.add_development_dependency "decidim-accountability", ">= 0.26.0", "< 0.28.0"
  s.add_development_dependency "decidim-budgets", ">= 0.26.0", "< 0.28.0"
  s.add_development_dependency "decidim-dev", ">= 0.26.0", "< 0.28.0"
  s.add_development_dependency "decidim-elections", ">= 0.26.0", "< 0.28.0"
  s.add_development_dependency "decidim-sortitions", ">= 0.26.0", "< 0.28.0"
end
