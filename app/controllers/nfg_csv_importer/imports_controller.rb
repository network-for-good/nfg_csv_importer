class NfgCsvImporter::ImportsController < NfgCsvImporter::ApplicationController
  include ActionView::Helpers::TextHelper
  #expose(:import) do
  #im = (params[:id].nil? ? Import.queued.new(import_params) : entity.imports.find_by_id(params[:id])).tap { |im| im.attributes = import_params unless request.get? }
  #end

  before_filter :load_entity
  before_filter :set_import_type
  before_filter :load_new_import, only: [:create, :new, :show]

  def create
    @import.imported_by = self.send("current_#{NfgCsvImporter.configuration.user_class.downcase}")
    @import.send("#{NfgCsvImporter.configuration.entity_field}=", @entity.id)
    if @import.save
      NfgCsvImporter::ProcessImportJob.perform_later(@import.id)
      flash[:notice] = t('flash_messages.import.create.notice')
      redirect_to import_path(@import)
    else
      render :action => 'new'
    end
  end

  def index
    @imports = @entity.imports.order_by_recent
  end

  def show
    @import = @entity.imports.find(params[:id])
  end

  protected
  # the standard event tracking (defined in application controller) attempts to include
  # the imported file, which crashes the write to the db. So here we only track the type of import
  def filtered_params
    { import_type: @import_type }
  end

  def import_params
    # params.require(:import).permit!
    params.fetch(:import, {}).merge(import_type: @import_type).permit!
  end

  def load_new_import
    @import ||= NfgCsvImporter::Import.queued.new(import_params)
  end

  def load_entity
    @entity ||= self.send "#{NfgCsvImporter.configuration.entity_class.downcase}".to_sym
  end

  def set_import_type
    @import_type ||= params[:import_type]
  end

end