module NfgCsvImporter
  class ImportPresenter < ApplicationPresenter
    def file_origination_types
      NfgCsvImporter::Import::PRE_PROCESING_TYPES
    end

    def get_started_modal_step(step:, heading_options: {}, body_options: {})
      h.ui.nfg(:typeface,
                heading: I18n.t("nfg_csv_importer.pre_processes.get_started_modal.file_origination_type.step#{step}.heading", **heading_options)) +

      h.ui.nfg(:typeface,
               body: I18n.t("nfg_csv_importer.pre_processes.get_started_modal.file_origination_type.step#{step}.body", **body_options))
    end

    def get_started_modal_image(step:)
      h.image_tag "nfg_csv_importer/illustrations/get-started-step#{step}.png"
    end

    def show_pick_import_type_button?
      file_origination_type_is_other?
    end

    def file_origination_type_is_other?
      params_for_file_origination_type == NfgCsvImporter::Import::PRE_PROCESSING_TYPE_OTHER_NAME
    end

    def show_time_estimate?
      !file_origination_type_is_other?
    end

    def knowledge_base_link_path
      I18n.t("nfg_csv_importer.urls.knowledge_base.walk_throughs.file_origination_types.#{params_for_file_origination_type}")
    end

    # This method (#import_type_value_for_pre_process_form) should not live here. This is here to help out and contain all of the custom logic that's empowering the UX design.
    # This should be managed outside of the presenter on the Import or somewhere else more appropriate
    def import_type_value_for_pre_process_form
      case params_for_file_origination_type
      when NfgCsvImporter::Import::PRE_PROCESSING_TYPE_CONSTANT_CONTACT_NAME then 'users'
      when NfgCsvImporter::Import::PRE_PROCESSING_TYPE_MAILCHIMP_NAME then 'users'
      when NfgCsvImporter::Import::PRE_PROCESSING_TYPE_PAYPAL_NAME then 'donations'
      else
        import_type.presence
      end
    end

    private

    def params_for_file_origination_type
      h.params[:file_origination_type] || h.params[:import].try([], :file_origination_type)
    end
  end
end