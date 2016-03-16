class NfgCsvImporter::ImportDefinition
  attr_accessor :imported_for

  def self.get_definition(import_type, imported_for)
    service = self.new
    service.imported_for = imported_for
    OpenStruct.new service.send(import_type)
  end
end
