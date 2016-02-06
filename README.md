= NfgCsvImporter

# Add the gem to the project's Gemfile
# Add an initializer to specify what classes need to be used for entity and user:
````
# config/initializers/nfg_csv_importer.rb
NfgCsvImporter.entity_class = "Entity"
NfgCsvImporter.user_class = "Admin"
````
# Add has_many relationships to your project's models:
````
# app/models/entity.rb
class Entity < ActiveRecord::Base
  has_many :imports, class_name: "NfgCsvImporter::Import"
end%
````