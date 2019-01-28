require File.expand_path("../test_app/config/environment.rb",  __FILE__)
require 'rspec/rails'
require 'rspec/rails/mocha'
require 'factory_girl_rails'
require 'shoulda/matchers'
Rails.backtrace_cleaner.remove_silencers!
ActiveRecord::Migrator.migrations_paths = 'spec/test_app/db/migrate'

#
# Load support files
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.mock_with :mocha
  config.use_transactional_fixtures = true
  config.infer_base_class_for_anonymous_controllers = false
  config.infer_spec_type_from_file_location!
  config.order = "random"
  config.include(Shoulda::Matchers::ActiveModel, type: :model)
  config.include(Shoulda::Matchers::ActiveRecord, type: :model)
  config.include Rails.application.routes.url_helpers
  config.include NfgCsvImporter::Engine.routes.url_helpers
  config.mock_with :mocha

 config.include SeleniumHelper, :type => :feature

 config.before(:suite) do
   DatabaseCleaner.strategy = :truncation
 end

 config.before(:each, js: true) do
   DatabaseCleaner.start
 end

 config.after(:each, js: true) do
   DatabaseCleaner.clean
 end
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

Capybara.register_driver :selenium do |app|
  Capybara::Selenium::Driver.new(app, :browser => :chrome)
end

Capybara.server = :webrick
