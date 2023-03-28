require File.expand_path('../boot', __FILE__)

# Pick the frameworks you want:
require "active_record/railtie"
require "action_controller/railtie"
require "action_mailer/railtie"
require "action_view/railtie"
require "sprockets/railtie"
require "jquery-rails"
require "active_storage/engine"
# require "rails/test_unit/railtie"

Bundler.require(*Rails.groups)
require "nfg_csv_importer"
require "spreadsheet"

module TestApp
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    config.default_from_address = 'noreply@networkforgood.com'
    config.action_mailer.default_url_options = { host: "example.com" }

    config.action_mailer.preview_path = "#{NfgCsvImporter::Engine.root}/lib/mailer_previews"
    # config.action_view.raise_on_missing_translations = true

    # config.active_record.sqlite3.represent_boolean_as_integer = true

        # This is a list of classes that the YAML parser is allowed to deserialize
    config.active_record.yaml_column_permitted_classes = [
      Symbol,
      Set,
      ActionController::Parameters,
      ActiveSupport::HashWithIndifferentAccess,
      Roo::Link,
      Spreadsheet::Link,
      ActionDispatch::Http::UploadedFile
    ]

  end
end

