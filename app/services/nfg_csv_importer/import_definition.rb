class NfgCsvImporter::ImportDefinition
  attr_accessor :imported_for, :imported_by

  def self.get_definition(import_type, imported_for, imported_by)
    definition = self.new
    definition.imported_for = imported_for
    definition.imported_by = imported_by
    NfgCsvImporter::ImportDefinitionDetails.new definition.send(import_type)
  end

  def self.import_types
    []
  end
end
