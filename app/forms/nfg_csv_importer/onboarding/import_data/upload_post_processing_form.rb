# frozen_string_literal: true

module NfgCsvImporter
  module Onboarding
    module ImportData
      class UploadPostProcessingForm < NfgCsvImporter::Onboarding::ImportData::BaseForm
        include NfgCsvImporter::Concerns::ImportServiceable
        include NfgCsvImporter::Concerns::ImportFileValidateable
        ## Add properties for your form below:

        property :import_file
        property :import_template_id

        validates :import_file, presence: true
        validate :import_validation
        validate :import_file_extension_validation
        validate :validate_max_number_of_rows_allowed

        def imported_by
          model.imported_by
        end

        def imported_for
          model.imported_for
        end

        def import_type
          model.import_type
        end

        def time_zone
          model.time_zone
        end

        private

        def validate_max_number_of_rows_allowed
          max_rows_allowed = NfgCsvImporter.configuration.max_number_of_rows_allowed
          return unless import_file && max_rows_allowed.present?

          if model.max_row_limit_exceeded?
            errors.add :base, I18n.t('nfg_csv_importer.onboarding.import_data.invalid_number_of_rows',
                                     num_rows: max_rows_allowed)
          end
        rescue StandardError => e
          # This shouldn't fail but just in case it does, log an error
          # and return nil so it doesn't block the import
          Rails.logger.error e.message
          nil
        end
      end
    end
  end
end
