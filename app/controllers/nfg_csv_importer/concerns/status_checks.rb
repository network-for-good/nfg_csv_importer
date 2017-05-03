module NfgCsvImporter
  module Concerns
    module StatusChecks
      extend ActiveSupport::Concern

      private

      def redirect_unless_uploaded_status
        if @import && !@import.uploaded?
          respond_to do |format|
            format.html do
              flash[:error] = I18n.t('import.cant_edit_or_reprocess')
              redirect_to import_path(@import)
            end
            format.all do
              return head :forbidden
            end
          end
        end
      end
    end
  end
end
