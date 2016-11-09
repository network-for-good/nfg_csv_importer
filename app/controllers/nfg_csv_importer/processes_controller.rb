class NfgCsvImporter::ProcessesController < NfgCsvImporter::ApplicationController

  before_filter :load_imported_for
  before_filter :load_import, only: [:create]

  def create
    NfgCsvImporter::ProcessImportJob.perform_later(@import.id)
    flash[:success] = "Your import has been queued for processing. You will be emailed when it is completed. You can refresh this page to get updates on the import's progress."
    redirect_to @import
  end
  alias_method :update, :create
end
