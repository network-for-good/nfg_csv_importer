class  NfgCsvImporter::Onboarding::ImportData::UploadPostProcessingForm < NfgCsvImporter::Onboarding::ImportData::BaseForm
  ## Add properties for your form below:
  property :import_file

  validates :import_file, presence: true
end
