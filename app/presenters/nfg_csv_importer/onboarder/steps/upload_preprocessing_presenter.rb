module NfgCsvImporter
  module Onboarder
    module Steps
      class UploadPreprocessingPresenter < NfgCsvImporter::Onboarder::OnboarderPresenter
        # To take advantage of custom header page text on this step
        #
        # Add a new entry based on the file_origination_type type_sym  to your yml file like this:
        #
        # on: config/locales/views/onboarding/import_data.yml
        #
        # import_data:
        #   upload_preprocessing:
        #     header:
        #       file_origination_type:
        #         paypal: "custom header..."
        #         mailchimp: "etc..."
        def header_page_text
          scope = [:nfg_csv_importer, :onboarding, :import_data, :upload_preprocessing]

          I18n.t(".header.file_origination_type.#{file_origination_type.type_sym}",
                  scope: scope,

                  # Fallback in the event a custom header hasn't been set.
                  default: I18n.t('.header.page',
                                  scope: scope,
                                  file_origination_type: file_origination_type.name,
                                  description_of_files: "they come in a 'package' and look like this: some_filename.csv"))
        end
      end
    end
  end
end