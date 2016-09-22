class NfgCsvImporter::ImportsController < NfgCsvImporter::ApplicationController
  include ActionView::Helpers::TextHelper

  before_filter :load_imported_for
  before_filter :set_import_type, only: [:create, :new]
  before_filter :load_new_import, only: [:create, :new]
  before_filter :load_import, only: [:show, :destroy]

  def create
    @import.imported_by = self.send("current_#{NfgCsvImporter.configuration.imported_by_class.downcase}")
    @import.number_of_records_with_errors = 0
    if @import.save
      NfgCsvImporter::ProcessImportJob.perform_later(@import.id)
      flash[:notice] = t(:notice, scope: [:import, :create])
      redirect_to import_path(@import)
    else
      render :action => 'new'
    end
  end

  def index
    @imports = @imported_for.imports.order_by_recent
  end

  def show
  end

  def destroy
    number_of_records = @import.imported_records.size
    @import.update_attribute(:status, NfgCsvImporter::Import.statuses[:deleting])
    @import.imported_records.find_in_batches(batch_size: NfgCsvImporter::ImportedRecord.batch_size) do |batch|
      NfgCsvImporter::DestroyImportJob.perform_later(batch.map(&:id), @import.id)
    end
    flash[:success] = t(:success, number_of_records: number_of_records, import_type: @import.import_type, scope: [:import, :destroy])
    redirect_to imports_path
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

  def load_import
    @import = @imported_for.imports.find(params[:id])
  end
end
