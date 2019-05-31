module NfgCsvImporter
  class ImportPresenter < ApplicationPresenter
    def pre_processing_types
      NfgCsvImporter::Import::PRE_PROCESING_TYPES
    end

    def get_started_modal_step(step:, heading_options: {}, body_options: {})
      h.ui.nfg(:typeface,
                heading: I18n.t("nfg_csv_importer.pre_processes.get_started_modal.pre_processing_type.step#{step}.heading", **heading_options)) +

      h.ui.nfg(:typeface,
               body: I18n.t("nfg_csv_importer.pre_processes.get_started_modal.pre_processing_type.step#{step}.body", **body_options))
    end

    def get_started_modal_image(step:)
      h.image_tag "nfg_csv_importer/illustrations/get-started-step#{step}.png"
    end

    def show_pick_import_type_button?
      pre_processing_type_is_other?
    end

    def link_to_skip_modal
      if pre_processing_type_is_other?
        path = h.nfg_csv_importer.import_type_pre_processes_path(pre_processing_type: params_for_pre_processing_type)

        skip_modal_link_scope = :other
      else
        path = h.nfg_csv_importer.new_pre_processes_path(pre_processing_type: params_for_pre_processing_type)

        skip_modal_link_scope = :third_party
      end

      h.link_to I18n.t("nfg_csv_importer.pre_processes.get_started_modal.pre_processing_type.buttons.skip.#{skip_modal_link_scope}"), path, remote: pre_processing_type_is_other?
    end

    def pre_processing_type_is_other?
      params_for_pre_processing_type == NfgCsvImporter::Import::PRE_PROCESSING_TYPE_OTHER_NAME
    end

    def show_time_estimate?
      !pre_processing_type_is_other?
    end

    def knowledge_base_link_path
      I18n.t("nfg_csv_importer.urls.knowledge_base.walk_throughs.pre_processing_types.#{params_for_pre_processing_type}")
    end

    # This method (#import_type_value_for_pre_process_form) should not live here. This is here to help out and contain all of the custom logic that's empowering the UX design.
    # This should be managed outside of the presenter on the Import or somewhere else more appropriate
    def import_type_value_for_pre_process_form
      case params_for_pre_processing_type
      when NfgCsvImporter::Import::PRE_PROCESSING_TYPE_CONSTANT_CONTACT_NAME then 'users'
      when NfgCsvImporter::Import::PRE_PROCESSING_TYPE_MAILCHIMP_NAME then 'users'
      when NfgCsvImporter::Import::PRE_PROCESSING_TYPE_PAYPAL_NAME then 'donations'
      else
        import_type.presence
      end
    end

    private

    def params_for_pre_processing_type
      h.params[:pre_processing_type] || h.params[:import][:pre_processing_type]
    end
  end
end