class NfgCsvImporter::ImportDefinition
  def self.get_definition(import_type)
    OpenStruct.new self.send(import_type)
  end
end
