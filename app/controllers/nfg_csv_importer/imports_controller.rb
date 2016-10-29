class NfgCsvImporter::ImportsController < NfgCsvImporter::ApplicationController
  include ActionView::Helpers::TextHelper

  before_filter :load_imported_for
  before_filter :set_import_type, only: [:create, :new]
  before_filter :load_new_import, only: [:create, :new]
  before_filter :load_import, only: [:show, :destroy, :edit, :update]

  def create
    @import.imported_by = self.send("current_#{NfgCsvImporter.configuration.imported_by_class.downcase}")
    @import.status = :uploaded
    @import.import_type = @import_type
    @import.imported_for = @imported_for
    if @import.save
      redirect_to edit_import_path(@import), notice: I18n.t('import.create.notice')
    else
      render :action => 'new'
    end
  end


  # Original def update
  # def update
  #   if @import.update(import_params)
  #     redirect_to @import
  #   else
  #     setup_edit
  #     render "edit"
  #   end
  # end

  # if failure, will update the edit page -- undesirable
  def update
    setup_edit
    import_params["fields_mapping"].each do |header_name, mapped_header_name|
      @header_name = header_name
      @import.fields_mapping[header_name] = mapped_header_name
    end
    if @import.save
      respond_to do |format|
        format.html { render "edit" }
        format.js { }
      end
    else
      respond_to do |format|
        format.html { redirect_to @import }
        format.js { }
      end
    end
  end



  def edit
    setup_edit
  end

  def index
    @imports = @imported_for.imports.order_by_recent
  end

  def show
  end

  def destroy
    number_of_records = @import.imported_records.size
    @import.destroy
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
    # params.require(:import).permit(fields_mapping: {})
    params[:import]
  end

  def load_new_import
    @import ||= NfgCsvImporter::Import.queued.new(import_params.merge(import_type: @import_type, imported_for: @imported_for))
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

  def setup_edit
    @first_x_rows = @import.first_x_rows
    @all_valid_columns = @import.all_valid_columns
    @headers = @import.header
    @fields_mapping = @import.fields_mapping
  end
end
