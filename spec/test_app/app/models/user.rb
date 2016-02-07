class User < ActiveRecord::Base
  has_many :imports, class_name: "NfgCsvImporter::Import"

  def name
    "#{first_name} #{last_name}"
  end
end