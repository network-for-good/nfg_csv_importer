$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "nfg_csv_importer/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "nfg_csv_importer"
  s.version     = NfgCsvImporter::VERSION
  s.authors     = ["Pavan Kuttagula", "Timothy King"]
  s.email       = ["pavan.kuttagula@effone.com", "timothy.king@networkforgood.com"]
  s.homepage    = "http://www.networkforgood.com"
  s.summary     = "A CSV importer for NFG Rails applications."

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.

  if s.respond_to?(:metadata)
    s.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes." unless ENV['TDDIUM']
  end

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", '~> 6.0'
  s.add_dependency "roo", '2.10.0'
  s.add_dependency "roo-xls"
  s.add_dependency "carrierwave"
  s.add_dependency "haml"
  s.add_dependency "jquery-rails"
  s.add_dependency "simple_form"
  s.add_dependency "coffee-script"
  s.add_dependency "sass-rails", "~> 6.0"

  # nfg_ui and nfg_onboarder while using rails_6 branches and not master
  # are called from the Gemfile
  # Once we move to rails_6 on master branches, remove from the Gemfile
  # and re-enable this dependency.
  # Note added: 5/5/22
  #
  # s.add_dependency "nfg_ui", "~> 0.15.0"
  # s.add_dependency "nfg_onboarder", "~> 0.0.3"

  s.add_dependency "reform-rails", '~> 0.2.3'
  s.add_dependency "premailer-rails", "~> 1.9", ">= 1.9.6"
  s.add_dependency 'aws-sdk-s3', '~> 1.66'
  s.add_dependency 'rubyzip', '~> 1.3.0'
  s.add_dependency 'sassc', '~> 2.0.1'

  s.add_development_dependency "sqlite3", '~> 1.4'
  s.add_development_dependency "rails-controller-testing"
  s.add_development_dependency "rspec-rails", '~> 4.0'
  s.add_development_dependency "rspec_junit_formatter"
  s.add_development_dependency "rspec-rails-mocha"
  s.add_development_dependency "capybara"
  s.add_development_dependency "capybara-screenshot"
  s.add_development_dependency "shoulda"
  s.add_development_dependency "shoulda-matchers"
  s.add_development_dependency "pry"
  s.add_development_dependency "pry-byebug"
  s.add_development_dependency "ejs"
  s.add_development_dependency "selenium-webdriver"
  s.add_development_dependency "sidekiq"
  s.add_development_dependency "database_cleaner"
  s.add_development_dependency "puma"
  s.add_development_dependency "factory_bot_rails"
end
