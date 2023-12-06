# frozen_string_literal: true

require "decidim/dev"

ENV["ENGINE_ROOT"] = File.dirname(__dir__)

Decidim::Dev.dummy_app_path = File.expand_path(File.join(__dir__, "decidim_dummy_app"))

require "decidim/dev/test/base_spec_helper"

require "decidim/comments/test"

engine_spec_dir = File.join(Dir.pwd, "spec")
Dir["#{engine_spec_dir}/proposals/shared/**/*.rb"].sort.each { |f| require f }

RSpec.configure do |config|
  config.backtrace_exclusion_patterns = [
    /actionpack/,
    /activerecord/,
    /activemodel/,
    /activesupport/,
    /actionview/,
    /railties/,
    /omniauth/,
    /puma/,
    /rack/,
    /cells/,
    /bundler/,
    /tilt/,
    /warden/,
    /rspec-expectations/,
    /rspec-core/
  ]
end
