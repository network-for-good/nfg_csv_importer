module NfgCsvImporter
  module Onboarder
    module Steps
      class FileOriginationTypeSelectionPresenter < NfgCsvImporter::Onboarder::OnboarderPresenter
        # To add a custom file_origination_type title to the file origination type radio buttons
        #
        # Add a `file_origination_type` heading to nfg_csv_importer.onboarding.import_data.file_origination_type_selection in your yml file.
        #
        # Then add an entry for each file_origination_type named after their #type_sym
        #
        # Example: config/locales/import_data.yml
        # en:
        #   nfg_csv_importer:
        #     onboarding:
        #       import_data:
        #         file_origination_type_selection:
        #           file_origination_type_title:
        #             paypal: 'Import PayPal Files'
        #             mailchimp: 'etc...'
        #
        # Fallsback to the file_origination_type.name
        def file_origination_type_title(file_origination_type:)
          I18n.t("nfg_csv_importer.onboarding.import_data.file_origination_type_selection.file_origination_type_title.#{file_origination_type.type_sym}", default: file_origination_type.name)
        end

        #
        # Used add a custom file_origination_type description to the file origination type radio buttons.
        # The default file description content contains "contacts and donations" but it does not make sense
        # for all enclosing applications, for example in the case of auctions the bidder import description
        # should contain "bidders" instead of "donations" or "contacts".
        # It falls back to the file_origination_type.description if no custom description is present.
        #
        # Example: config/locales/import_data.yml
        # en:
        #   nfg_csv_importer:
        #     onboarding:
        #       import_data:
        #         file_origination_type_selection:
        #           file_origination_type_description:
        #             self_import_csv_xls: "Import bidders from a CSV or XLS file."
        #
        def file_origination_type_description(file_origination_type:)
          I18n.t(file_origination_type.type_sym, scope: %i[nfg_csv_importer onboarding import_data file_origination_type_selection file_origination_type_description], default: file_origination_type.description)
        end
      end
    end
  end
end