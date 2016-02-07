$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "nfg_csv_importer/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "nfg_csv_importer"
  s.version     = NfgCsvImporter::VERSION
  s.authors     = ["Timothy King"]
  s.email       = ["timothy.king@networkforgood.com"]
  s.homepage    = "http://www.networkforgood.com"
  s.summary     = "A CSV importer for NFG Rails applications."

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if s.respond_to?(:metadata)
    s.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  s.files = Dir["{app,config,db,lib}/**/*", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2"
  s.add_dependency "roo"
  s.add_dependency "carrierwave"
  s.add_dependency "haml"
  s.add_dependency "simple_form"

  s.add_development_dependency "sqlite3"
  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "rspec-rails-mocha"
  s.add_development_dependency "factory_girl_rails"
  s.add_development_dependency "shoulda-matchers"
end
