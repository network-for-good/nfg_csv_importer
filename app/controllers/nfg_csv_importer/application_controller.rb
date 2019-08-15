module NfgCsvImporter
  class ApplicationController < NfgCsvImporter.configuration.base_controller_class.constantize
    include NfgCsvImporter::Concerns::ImportAttributeLoaders
    helper NfgCsvImporter::ImportsHelper
    helper NfgUi::ApplicationHelper
  end
end
