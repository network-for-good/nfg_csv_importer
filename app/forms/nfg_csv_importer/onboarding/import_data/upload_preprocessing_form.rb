class  NfgCsvImporter::Onboarding::ImportData::UploadPreprocessingForm < NfgCsvImporter::Onboarding::ImportData::BaseForm
  property :pre_processing_files

  validates :pre_processing_files, presence: true
end
