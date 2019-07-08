module NfgCsvImporter
  class ApplicationController < NfgCsvImporter.configuration.base_controller_class.constantize
    include NfgCsvImporter::Concerns::ImportAttributeLoaders
    helper NfgCsvImporter::ImportsHelper
    helper NfgUi::ApplicationHelper

  private

    def load_import
      @import = imported_for.imports.find(params[:id] || params[:import_id])
    end

  end
end
