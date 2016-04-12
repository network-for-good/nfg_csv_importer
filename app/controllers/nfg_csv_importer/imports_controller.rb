class NfgCsvImporter::ImportsController < NfgCsvImporter::ApplicationController
  include ActionView::Helpers::TextHelper

  before_filter :load_imported_for
  before_filter :set_import_type, only: [:create, :new]
  before_filter :load_new_import, only: [:create, :new, :show]

  def create
    @import.imported_by = self.send("current_#{NfgCsvImporter.configuration.imported_by_class.downcase}")
    if @import.save
      NfgCsvImporter::ProcessImportJob.perform_later(@import.id)
      flash[:notice] = t('flash_messages.import.create.notice')
      redirect_to import_path(@import)
    else
      render :action => 'new'
    end
  end

  def index
    @imports = @imported_for.imports.order_by_recent
  end

  def show
    @import = @imported_for.imports.find(params[:id])
  end

  protected
  # the standard event tracking (defined in application controller) attempts to include
  # the imported file, which crashes the write to the db. So here we only track the type of import
  def filtered_params
    { import_type: @import_type }
  end

  def import_params
    # params.require(:import).permit!
    params.fetch(:import, {}).merge(import_type: @import_type, imported_for: @imported_for).permit!
  end

  def load_new_import
    @import ||= NfgCsvImporter::Import.queued.new(import_params)
  end

  def load_imported_for
    @imported_for ||= self.send "#{NfgCsvImporter.configuration.imported_for_class.downcase}".to_sym
  end

  def set_import_type
    redirect_to imports_path unless params[:import_type]
    @import_type ||= params[:import_type]
  end

end