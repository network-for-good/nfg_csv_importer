# frozen_string_literal: true

module NfgCsvImporter
  module Onboarding
    module ImportData
      class UploadPostProcessingForm < NfgCsvImporter::Onboarding::ImportData::BaseForm
        include NfgCsvImporter::Concerns::ImportServiceable
        include NfgCsvImporter::Concerns::ImportFileValidateable
        ## Add properties for your form below:

        property :import_file

        validates :import_file, presence: true
        validate :import_validation
        validate :import_file_extension_validation

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
      end
    end
  end
end
