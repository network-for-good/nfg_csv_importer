NfgCsvImporter.configure do |config|
  config.imported_for_class = "Entity"
  config.imported_by_class = "User"
  config.base_controller_class = "ApplicationController"
  config.from_address = Rails.configuration.default_from_address
  config.reply_to_address = Rails.configuration.default_from_address
  config.imported_for_subdomain = :subdomain
end
