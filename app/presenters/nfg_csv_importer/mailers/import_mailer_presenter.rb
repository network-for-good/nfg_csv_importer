module NfgCsvImporter
  module Mailers
    # Pass the @import into the model arg for ImportMailerPresenter
    class ImportMailerPresenter < NfgCsvImporter::GemPresenter
      def status_result_alert_message
        I18n.t("send_import_result.alert.#{status}", scope: i18n_scope)
      end

      private

      def i18n_scope
        [:nfg_csv_importer, :mailers, :import]
      end
    end
  end
end