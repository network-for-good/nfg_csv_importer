class  NfgCsvImporter::Onboarding::ImportData::ImportTypeForm < NfgCsvImporter::Onboarding::ImportData::BaseForm
  ## Add properties for your form below:
  property :import_type

  validates :import_type, presence: true
end
