class NfgCsvImporter::ProcessesController < NfgCsvImporter::ApplicationController
  include NfgCsvImporter::Concerns::StatusChecks

  before_action :load_imported_for
  before_action :load_import
  before_action :redirect_unless_uploaded_status

  def create
    @import.queued!
    NfgCsvImporter::ImportMailer.send_import_result(@import).deliver_now
    NfgCsvImporter::ProcessImportJob.perform_async(@import.id)
    redirect_to import_path(@import, redirected_from_review: true), notice: I18n.t('process.create.notice')
  end
end
