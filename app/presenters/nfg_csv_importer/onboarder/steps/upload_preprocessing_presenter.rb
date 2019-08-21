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
        #         page:
        #           paypal: "custom header..."
        #           mailchimp: "etc..."
        def header_page_text
          I18n.t(".header.file_origination_type.page.#{file_origination_type.type_sym}",
                  scope: i18n_scope,

                  # Fallback in the event a custom header hasn't been set.
                  default: I18n.t('.header.page',
                                  scope: i18n_scope,
                                  file_origination_type: file_origination_type.name,
                                  description_of_files: "they come in a 'package' and look like this: some_filename.csv"))
        end

        # import_data:
        #   upload_preprocessing:
        #     header:
        #       file_origination_type:
        #         message:
        #           paypal: "custom message text..."
        #           mailchimp: "custom message..."
        def header_message_text
          I18n.t(".header.file_origination_type.message.#{file_origination_type.type_sym}",
                  scope: i18n_scope,

                  # fallback
                  default: I18n.t('.header.message', file_origination_type: file_origination_type.name, scope: i18n_scope)
                  )
        end

        private

        def i18n_scope
          [:nfg_csv_importer, :onboarding, :import_data, :upload_preprocessing]
        end
      end
    end
  end
end