class NfgCsvImporter::ProcessesController < NfgCsvImporter::ApplicationController

  before_filter :load_imported_for
  before_filter :load_import, only: [:create]

  def create
    NfgCsvImporter::ProcessImportJob.perform_later(@import.id)
    redirect_to import_path(@import, redirected_from_review: true), notice: I18n.t('process.create.notice')
  end
  alias_method :update, :create
end
