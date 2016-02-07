NfgCsvImporter.configure do |config|
  config.entity_class = "Entity"
  config.user_class = "User"
  config.base_controller_class = "ApplicationController"
  config.user_method = :current_user
end
