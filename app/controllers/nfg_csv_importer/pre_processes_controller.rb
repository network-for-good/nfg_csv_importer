class NfgCsvImporter::PreProcessesController < NfgCsvImporter::ApplicationController
  before_action :set_import_type
  before_action :set_pre_processing_type
  before_action :set_import
  before_action :set_import_presenter

  # Hacked in so that import_type can successfully and easily kick off a imports#new format.js
  before_action :load_imported_for, only: [:import_type, :new]
  before_action :load_imported_by, only: [:import_type, :new]

  def get_started
    respond_to { |format| format.js }
  end

  def import_type
    respond_to { |format| format.js { render '/nfg_csv_importer/imports/new' } }
  end

  def new
    # Fake import_type -- not sure if this @previous_imports is needed.
    @previous_imports = @imported_for.imports.order_by_recent.where(import_type: @import_type)
  end

  # Make it feel like a preview is being created so it hacks it
  # and renders the generate preview modal for UX
  # workflow
  def create
    respond_to { |format| format.js }
  end

  private

  def set_import_presenter
    @import_presenter = NfgCsvImporter::ImportPresenter.new(@import, view_context)
  end

  def set_pre_processing_type
    @pre_processing_type = params[:pre_processing_type] || params[:import][:pre_processing_type]
  end

  def set_import
    @import = NfgCsvImporter::Import.new
  end

  def set_import_type
    @import_type = params[:import].present? ? params[:import][:import_type] : :user

  end

  def permitted_params
    params.require(:import).permit(:pre_processing_type, :import_file, :import_type)
  end
end
