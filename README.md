# NfgCsvImporter

1. Add the gem to the project's Gemfile
2. Add an initializer to specify what classes need to be used for entity and user:

    ````
    # config/initializers/nfg_csv_importer.rb
    NfgCsvImporter.configure do |config|
      config.entity_class = "Entity"
      config.user_class = "Admin"
      config.base_controller_cass = "ApplicationController"
      config.user_method = :current_user
      config.from_address = Rails.configuration.default_from_address
      config.reply_to_address = Rails.configuration.default_from_address
    end
    ````

3. Add has_many relationships to your project's models:

    ````
    # app/models/entity.rb
    class Entity < ActiveRecord::Base
      has_many :imports, class_name: "NfgCsvImporter::Import"
    end
    ````

4. Add importer definitions in app/imports
5. Configure uploaders