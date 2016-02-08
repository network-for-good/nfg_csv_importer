NfgCsvImporter.configure do |config|
  config.entity_class = "Entity"
  config.user_class = "User"
  config.base_controller_class = "ApplicationController"
  config.user_method = :current_user
  config.from_address = Rails.configuration.default_from_address
  config.reply_to_address = Rails.configuration.default_from_address
end
