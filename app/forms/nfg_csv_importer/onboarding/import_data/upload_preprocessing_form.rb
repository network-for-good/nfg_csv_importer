# frozen_string_literal: true

module NfgCsvImporter
  module Onboarding
    module ImportData
      class UploadPreprocessingForm < NfgCsvImporter::Onboarding::ImportData::BaseForm
        property :pre_processing_files

        validates :pre_processing_files, presence: true
      end
    end
  end
end
