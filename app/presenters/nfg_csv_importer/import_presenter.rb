# frozen_string_literal: true

module NfgCsvImporter
  class ImportPresenter < NfgCsvImporter::GemPresenter
    # Grabs the stored, official #name of the FileOriginationType
    #
    # This is humanized and gramatically correct.
    # This is preferred over import.file_origination_type (which returns something like 'paypal')
    # Since we want the brand-version of the name "PayPal" and not a titleized version, 'Paypal'
    def file_origination_type_name
      # If a file origination type wasn't set, it's almost guaranteed to be a self-imported file from the past.
      if file_origination_type.nil?
        NfgCsvImporter::FileOriginationTypes::Manager.default_file_origination_type.name
      else
        file_origination_type.name
      end
    end

    def import_note
      onboarding_session.step_data['import_data'].try(:[], :upload_preprocessing).try(:[], 'note')
    end

    def show_files?
      import_file&.present? || error_file&.present? || pre_processing_files&.any?
    end
    alias show_download_link? show_files?

    def show_slat_actions?
      show_files? || can_be_deleted?(h.current_user)
    end
  end
end
