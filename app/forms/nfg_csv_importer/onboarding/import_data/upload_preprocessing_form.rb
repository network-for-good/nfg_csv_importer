# frozen_string_literal: true

module NfgCsvImporter
  module Onboarding
    module ImportData
      class UploadPreprocessingForm < NfgCsvImporter::Onboarding::ImportData::BaseForm
        include NfgCsvImporter::Concerns::ImportFileValidateable

        property :pre_processing_files
        property :note, virtual: true

        VALID_FILE_EXTENSIONS = %w[csv xls xlsx].freeze

        validates :pre_processing_files, presence: true
        validate :import_file_extension_validation

        private

        def import_file_extension_validation
          return unless pre_processing_files.any? do |signed_id|
            unless signed_id.is_a?(ActiveStorage::Attachment)
              file_extension = NfgCsvImporter::ActiveStorageHelper.get_file_extension(
                NfgCsvImporter::ActiveStorageHelper.find_by_signed_id(signed_id)
              )
              file_extension_invalid?(file_extension, valid_file_extensions)
            end
          end

          errors.add :pre_processing_files, file_extension_error_string(multiple: pre_processing_files.count > 1, valid_extensions: valid_file_extensions)
        end

        def valid_file_extensions
          return @valid_file_extensions if @valid_file_extensions.present?

          @valid_file_extensions ||= VALID_FILE_EXTENSIONS if !model.respond_to?(:file_origination_type) || model&.file_origination_type.nil?
          @valid_file_extensions ||= NfgCsvImporter::FileOriginationTypes::Base.get_valid_file_extensions(file_origination_type_name)
        end

        def file_origination_type_name
          model.file_origination_type.type_sym&.to_s&.camelcase
        end
      end
    end
  end
end
