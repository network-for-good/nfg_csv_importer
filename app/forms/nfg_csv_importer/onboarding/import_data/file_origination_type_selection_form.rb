class  NfgCsvImporter::Onboarding::ImportData::FileOriginationTypeSelectionForm < NfgCsvImporter::Onboarding::ImportData::BaseForm
  ## Add properties for your form below:
  property :file_origination_type

  validates_presence_of :file_origination_type
end
