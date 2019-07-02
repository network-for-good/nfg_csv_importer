# Load the Rails application.
require File.expand_path('../application', __FILE__)

require 'yaml'
config = YAML::load(ERB.new(IO.read(File.join(Rails.root, 'config', 'api-keys.yml'))).result)
config_hash = ActiveSupport::HashWithIndifferentAccess.new(config)
if config_hash[Rails.env]
  APP_CONFIG = config_hash[:defaults].deep_merge(config_hash[Rails.env])
else
  APP_CONFIG = config_hash[:defaults]
end
# Initialize the Rails application.
Rails.application.initialize!
