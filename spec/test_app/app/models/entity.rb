class Entity < ActiveRecord::Base
  has_many :imports, class_name: "NfgCsvImporter::Import", foreign_key: :imported_for_id, dependent: :destroy
  has_many :users
end