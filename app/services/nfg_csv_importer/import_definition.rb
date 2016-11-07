class NfgCsvImporter::ImportDefinition
  attr_accessor :imported_for

  def self.get_definition(import_type, imported_for)
    definition = self.new
    definition.imported_for = imported_for
    NfgCsvImporter::ImportDefinitionDetails.new definition.send(import_type)
  end

  def self.import_types
    []
  end
end
