# frozen_string_literal: true

module NfgCsvImporter
  module Onboarding
    module ImportData
      class UploadPreprocessingForm < NfgCsvImporter::Onboarding::ImportData::BaseForm
        include NfgCsvImporter::Concerns::ImportFileValidateable

        property :pre_processing_files

        VALID_FILE_EXTENSIONS = %w[csv xls xlsx].freeze

        validates :pre_processing_files, presence: true
        validate :import_file_extension_validation

        private

        def import_file_extension_validation
          return unless pre_processing_files.any? do |signed_id|
            file_extension = NfgCsvImporter::ActiveStorageHelper.get_file_extension(
              NfgCsvImporter::ActiveStorageHelper.find_by_signed_id(signed_id)
            )
            file_extension_invalid?(file_extension, VALID_FILE_EXTENSIONS)
          end

          errors.add :pre_processing_files, file_extension_error_string(multiple: pre_processing_files.count > 1)
        end
      end
    end
  end
end
