module NfgCsvImporter
  module Onboarder
    module Steps
      class FileOriginationTypeSelectionPresenter < NfgCsvImporter::Onboarder::OnboarderPresenter
        # Shows or hides the file origiation type's #name
        # based on a manually generated blacklist
        #
        # This should probably be set on the host app, for now this manually
        # turns on or off the file origination type's #name as a string
        # on the file origination type radio button partial:
        # app/views/nfg_csv_importer/onboarding/import_data/file_origination_type_selection/_file_origination_type_radio_button.html.haml
        def show_file_origination_type_name?(type_sym = '')
          file_origination_types_that_require_names_to_be_visible.include?(type_sym.to_s)
        end

        private

        def file_origination_types_that_require_names_to_be_visible
          %w[self_import_csv_xls send_to_nfg]
        end
      end
    end
  end
end