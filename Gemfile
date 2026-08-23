source "https://rubygems.org"

# Declare your gem's dependencies in nfg_csv_importer.gemspec.
# Bundler will treat runtime dependencies like base dependencies, and
# development dependencies will be added by default to the :development group.
gemspec

# Declare any dependencies that are still in development here instead of in
# your gemspec. These might include edge Rails or gems from your path or
# Git. Remember to move these dependencies to your gemspec before releasing
# your gem to rubygems.org.
gem 'reform-rails', '~> 0.2.3'
gem 'nfg_onboarder', git: 'https://github.com/network-for-good/nfg_onboarder', branch: 'rails_7_2'

# Security floors for SCA root causes (NFG-4218). Each entry is the gem the CVE
# actually lives in, not the direct parent Snyk attributed it to. Pinned here so a
# future `bundle update` cannot silently regress the lockfile below the fix.
gem 'rails', '~> 7.2.0', '>= 7.2.3.2' # CVE-2026-66066, CVE-2026-33174, CVE-2026-33195, CVE-2025-24293: Active Storage / Action Pack
gem 'net-imap', '>= 0.5.15'           # CVE-2026-47240, CVE-2026-42246, CVE-2026-42256, CVE-2026-42257
gem 'websocket-driver', '>= 0.8.2'    # CVE-2026-61666
gem 'rack', '>= 3.1.21'               # CVE-2026-34830, CVE-2026-34230, CVE-2026-34826 (3.0.x has no fix line)
gem 'thor', '>= 1.4.0'                # CVE-2025-54314 (disputed upstream; bump is free)
gem 'nokogiri', '>= 1.19.4'           # vendored libxml2/libxslt: CVE-2025-49794/95/96, CVE-2025-6021, CVE-2025-24928, CVE-2024-56171, CVE-2024-34459

group :development do
  gem 'listen'
  gem 'better_errors' # displays errors in the browser better
  gem "binding_of_caller", "1.0.1"  # allows for initialization of a REPL at the location of the error
  gem 'factory_bot_rails'
end

# so we can play with the amount of time allowed before opening the browser
# gem 'konacha', github: "network-for-good/konacha", branch: 'master'

# Our version upgrades the modules to the current versions
# gem 'konacha-chai-matchers', :git => 'https://github.com/network-for-good/konacha-chai-matchers.git', branch: 'master'

# To use debugger
# gem 'debugger'
