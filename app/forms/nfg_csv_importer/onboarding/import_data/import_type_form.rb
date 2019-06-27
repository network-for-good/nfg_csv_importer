# frozen_string_literal: true

module NfgCsvImporter
  module Onboarding
    module ImportData
      class  ImportTypeForm < NfgCsvImporter::Onboarding::ImportData::BaseForm
        ## Add properties for your form below:
        property :import_type

        validates :import_type, presence: true
      end
    end
  end
end
