class Entity < ActiveRecord::Base
  has_many :imports, class_name: "NfgCsvImporter::Import"
end