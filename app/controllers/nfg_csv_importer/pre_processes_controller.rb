class NfgCsvImporter::PreProcessesController < NfgCsvImporter::ApplicationController
  before_action :set_pre_processing_type
  before_action :set_import

  def get_started
    @import_presenter = NfgCsvImporter::ImportPresenter.new(@import, view_context)
    respond_to { |format| format.js }
  end

  private

  def set_pre_processing_type
    @pre_processing_type = params[:import][:pre_processing_type]
  end

  def set_import
    @import = NfgCsvImporter::Import.new
  end
end
