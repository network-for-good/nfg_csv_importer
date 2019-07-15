module NfgCsvImporter
  class ImportPresenter < NfgCsvImporter::GemPresenter
    # Grabs the stored, official #name of the FileOriginationType
    #
    # This is humanized and gramatically correct.
    # This is preferred over import.file_origination_type (which returns something like 'paypal')
    # Since we want the brand-version of the name "PayPal" and not a titleized version, 'Paypal'
    def file_origination_type_name
      # If a file origination type wasn't set, it's almost guaranteed to be a self-imported file from the past.
      type = file_origination_type.present? ? file_origination_type : 'self_import_csv_xls'

       NfgCsvImporter::FileOriginationTypes::Manager.new(NfgCsvImporter.configuration).type_for(type)&.name
    end
  end
end