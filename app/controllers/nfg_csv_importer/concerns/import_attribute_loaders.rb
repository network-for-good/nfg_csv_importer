module NfgCsvImporter
  module Concerns
    module ImportAttributeLoaders
      extend ActiveSupport::Concern

      private

      def load_imported_by
        # this is typically a user, like an admin
        @imported_by ||= self.send("current_#{NfgCsvImporter.configuration.imported_by_class.downcase}")
      end

      def load_imported_for
        # this is typically the multi-tenant object, like an entity or site
        @imported_for ||= self.send "#{NfgCsvImporter.configuration.imported_for_class.downcase}".to_sym
      end

      def load_import
        @import = @imported_for.imports.find(params[:id] || params[:import_id])
      end
    end
  end
end

