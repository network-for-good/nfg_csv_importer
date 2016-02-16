# NfgCsvImporter

## Setup and Configuration
1. Add the gem to the project's Gemfile

    ````
    gem nfg_csv_importer
    ````

2. Add an initializer to set configuration values.

    ````
    # config/initializers/nfg_csv_importer.rb
    NfgCsvImporter.configure do |config|
      config.entity_class = "Entity"
      config.user_class = "Admin"
      config.base_controller_class = "ApplicationController"
      config.from_address = Rails.configuration.default_from_address
      config.reply_to_address = Rails.configuration.default_from_address
    end
    ````

3. Add has_many relationships to any relevant models.

    ````
    # app/models/entity.rb
    class Entity < ActiveRecord::Base
      has_many :imports, class_name: "NfgCsvImporter::Import"
    end
    ````

5. Copy and run migrations to create the import and import_records tables:
    ````
    rake nfg_csv_importer:install:migrations && rake db:migrate
    ````

6. Mount the uploader in `config/routes.rb`:
    ````
    mount NfgCsvImporter::Engine => "/admin"
    ````

7. Configure your ActiveJob backend (use ankane/activejob_backport for Rails < 4.2)
8. Set any neccessary storage options for Carrierwave in `config/initializers/carrierwave.rb`.

## Create Importer Definitions
Create the file `app/imports/import_definition.rb` containing a class called `ImportDefinition` inheriting from NfgCsvImporter::ImportDefinition`. Within this class, define a class method for each import type. This class method should contain a hash of options that pertain to that particular import type.
````
class ImportDefinition < NfgCsvImporter::ImportDefinition
  class << self
    def my_new_import
      {
        required_columns: %w{ foo bar },
        optional_columns: %w{baz},
        default_values: { "foo" => lambda { |row| row["email"][/[^@]+/] } },
        class_name: "TargetModel",
        alias_attributes: [],
        column_descriptions: { "foo" => "A description of the foo column", "bar" => "etc." },
        description: %Q{ A description of what sort of data this import is used for. }
      }
    end
  end
end
````

## Create Optional Import Services
For more fine grained control over the import business logic, you can write your own import service class. It should use the name of the model and inherit from `NfgCsvImporter::ImportService`.
````
class MyModelImportService < NfgCsvImporter::ImportService
end
````

## Create Optional Import Pseudo Model
If you need more control over how each row is written to the database, you can define a pseudo model class that includes `ActiveModel::Model`. Make sure it has a `#save` method. In your ImportDefinition class method (see above), set the class_name to a string representation of your new pseudo model.
````
class MyImport
  include ActiveModel::Model

  # do stuff

  def save
    MyRealModel.create(attributes)
  end
end
````
