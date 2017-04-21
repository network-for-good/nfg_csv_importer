module NfgCsvImporter
  class ApplicationController < NfgCsvImporter.configuration.base_controller_class.constantize
    helper NfgCsvImporter::ImportsHelper

  private

    def load_imported_by
      @imported_by ||= self.send("current_#{NfgCsvImporter.configuration.imported_by_class.downcase}")
    end

    def load_imported_for
      @imported_for ||= self.send "#{NfgCsvImporter.configuration.imported_for_class.downcase}".to_sym
    end

    def load_import
      @import = @imported_for.imports.find(params[:id] || params[:import_id])
    end

  end
end
