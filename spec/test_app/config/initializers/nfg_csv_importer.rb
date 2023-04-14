NfgCsvImporter.configure do |config|
  config.imported_for_class = "Entity"
  config.imported_by_class = "User"
  config.base_controller_class = "ApplicationController"
  config.from_address = Rails.configuration.default_from_address
  config.reply_to_address = Rails.configuration.default_from_address
  config.imported_for_subdomain = :subdomain
  config.additional_file_origination_types = [:paypal, :send_to_nfg]
  config.disable_import_initiation_message = -> (user) { user.last_name == 'noob' ? "You can't see it" : nil }
  config.max_number_of_rows_allowed = 50000
  config.high_priority_queue_name = :my_fine_queue
  config.process_import_job_sidekiq_options = { unique_for: 30.minutes }
  config.destroy_import_job_sidekiq_options = { backtrace: true }
end
