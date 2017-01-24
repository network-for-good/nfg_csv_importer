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
      config.imported_for_class = "Entity"
      config.imported_by_class = "Admin"
      config.base_controller_class = "ApplicationController"
      config.from_address = Rails.configuration.default_from_address
      config.reply_to_address = Rails.configuration.default_from_address
    end
    ````

3. Add has_many relationships to any relevant models. Make sure you specify the foreign key.

    ````
    # app/models/entity.rb
    class Entity < ActiveRecord::Base
      has_many :imports, class_name: "NfgCsvImporter::Import", foreign_key: :imported_for_id
    end

    # app/models/user.rb
    class User
      has_many :imports, class_name: "NfgCsvImporter::Import", foreign_key: :imported_by_id
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

## Set the Time.zone used on imports
By default, the importer gem will use Eastern Time as the time zone for date time fields when importing. You can override this by providing a time_zone method on the import_for object. If that method exists and returns something, the importer will set the Time.zone equal to the returned value for the duration of the import

## Provide links to all of the imports on the import index page
If you add a class method called import_types to your import definition file, the engine will display links to each of those imports new page at the top of the import index page
````
  def self.import_types
    [:user, :donation]
  end
````
The above will cause the imports/index page to display links to new?import_type=user and new?import_type=donation

## Styling the imports new page
To improve the styling of the imports new page, add a require statement to your application.css (or scss) file
````
*= require nfg_csv_importer/application
````

# Development
## Running Specs
If running specs for the first time, you will need to setup the test database
````
> cd spec/test_app
> bundle exec rake db:setup
````

In the future, you may need to bring your database up to date
````
> cd spec/test_app
> bundle exec rake db:migrate
````

To run specs, from the root of the project
````
bundle exec rspec spec
````

## Javascript Specs
We use the mocha javascript testing library and the Chai expectations library. The tests have to be housed in the Test App in the spec/test_app/spec/javascripts/ folder.

To run the tests, navigate to the test_app
````
cd spec/test_app
````

then use the following command to start the server
````
bundle exec rake konacha:serve
````

Then browse to http://localhost:3500/
