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
      @import.update(fields_mapping: NfgCsvImporter::FieldsMapper.new(@import).call)
      @import.service.maybe_set_import_number_of_records
      redirect_to edit_import_path(@import), notice: I18n.t('import.create.notice')
    else
      render :action => 'new'
    end
  end

  # if failure, will update the edit page -- undesirable
  def update
    import_params["fields_mapping"].each do |header_name, mapped_field_name|
      next unless @import.fields_mapping.has_key?(header_name) # don't do an assignment if something strange was submitted
      @import.fields_mapping[header_name] = mapped_field_name
      @mapped_column = @import.mapped_fields(header_name)
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
    @first_x_rows = @import.first_x_rows
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
    params.fetch(:import, {}).merge(import_type: @import_type, imported_for: @imported_for).permit!
  end

  def load_new_import
    @import ||= NfgCsvImporter::Import.queued.new(import_params.merge(import_type: @import_type, imported_for: @imported_for))
  end

  def set_import_type
    redirect_to imports_path unless params[:import_type]
    @import_type ||= params[:import_type]
  end
end
