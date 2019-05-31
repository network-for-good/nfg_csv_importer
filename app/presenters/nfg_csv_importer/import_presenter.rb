module NfgCsvImporter
  class ImportPresenter < ApplicationPresenter
    def pre_processing_types
      %w[mailchimp paypal constant_contact other]
    end

    def get_started_modal_steps(step:, heading_options: {}, body_options: {})
      h.ui.nfg(:typeface, heading: I18n.t("nfg_csv_importer.pre_processes.get_started_modal.pre_processing_type.step#{step}.heading", **heading_options)) +
      h.ui.nfg(:typeface, body: I18n.t("nfg_csv_importer.pre_processes.get_started_modal.pre_processing_type.step#{step}.body", **body_options))
    end
  end
end