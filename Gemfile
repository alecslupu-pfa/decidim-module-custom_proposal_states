# frozen_string_literal: true

source "https://rubygems.org"

ruby RUBY_VERSION

gem "decidim", "~> 0.27"
gem "decidim-custom_proposal_states", path: "."
gem "decidim-elections", "~> 0.27"

gem "bootsnap", "~> 1.4"
gem "puma", ">= 4.3"

group :development, :test do
  gem "byebug", "~> 11.0", platform: :mri

  gem "faker"

  gem "decidim-dev", "~> 0.27"

  gem "rubocop-performance"
  gem "simplecov", require: false
end

group :development do
  gem "letter_opener_web", "~> 2.0"
  gem "listen", "~> 3.1"
  gem "spring", "~> 2.0"
  gem "spring-watcher-listen", "~> 2.0"
  gem "web-console", "~> 4.2"
end

group :test do
  gem "rubocop-faker"
end
