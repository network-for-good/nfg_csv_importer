source "https://rubygems.org"

# Declare your gem's dependencies in nfg_csv_importer.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.
gem 'nfg_onboarder', git: 'https://github.com/network-for-good/nfg_onboarder.git', branch: 'rails_6'
gem 'reform-rails', '~> 0.1.7'

group :development do
  gem 'better_errors' # displays errors in the browser better
  gem "binding_of_caller" # allows for initialization of a REPL at the location of the error
  gem 'factory_bot_rails'
end

# so we can play with the amount of time allowed before opening the browser
# gem 'konacha', github: "network-for-good/konacha", branch: 'master'

# Our version upgrades the modules to the current versions
# gem 'konacha-chai-matchers', :git => 'https://github.com/network-for-good/konacha-chai-matchers.git', branch: 'master'

# To use debugger
# gem 'debugger'
