class NfgCsvImporter::ProcessesController < NfgCsvImporter::ApplicationController
  include NfgCsvImporter::Concerns::StatusChecks

  before_filter :load_imported_for
  before_filter :load_import
  before_filter :redirect_unless_uploaded_status

  def create
    @import.queued!
    NfgCsvImporter::ProcessImportJob.perform_later(@import.id)
    redirect_to import_path(@import, redirected_from_review: true), notice: I18n.t('process.create.notice')
  end
end
