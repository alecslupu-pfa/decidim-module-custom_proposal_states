# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

gem "decidim", github: "decidim/decidim", ref: "release/0.26-stable"
gem "decidim-custom_proposal_states", path: "."
gem "decidim-elections", github: "decidim/decidim", ref: "release/0.26-stable"

gem "bootsnap"
gem "uglifier", "~> 4.1"

group :development, :test do
  gem "faker"

  gem "decidim-dev", github: "decidim/decidim", ref: "release/0.26-stable"

  gem "rubocop-performance"
  gem "simplecov", require: false
end

group :development do
  gem "letter_opener_web", "~> 1.3"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 3.5"
end

group :test do
  gem "rubocop-faker"
end
