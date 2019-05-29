class NfgCsvImporter::PreProcessesController < NfgCsvImporter::ApplicationController
  before_action :set_pre_process_type

  def get_started
    respond_to { |format| format.js }
  end

  private

  def set_pre_process_type
    @pre_process_type = params[:pre_process_type]
  end
end
