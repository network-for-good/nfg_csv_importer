class NfgCsvImporter::ImportsController < NfgCsvImporter::ApplicationController
  include ActionView::Helpers::TextHelper
  include NfgCsvImporter::Concerns::StatusChecks

  before_action :load_imported_for
  before_action :load_imported_by
  before_action :set_import_type, only: [:create, :new, :template]
  before_action :load_new_import, only: [:create, :new, :template]
  before_action :load_import, only: [:show, :destroy, :edit, :update]
  before_action :authorize_user, except: [:index]
  before_action :redirect_unless_uploaded_status, only: [:edit, :update]
  skip_after_action :intercom_rails_auto_include, only: :edit, if: :iframe_param_present?

  def new
    @previous_imports = @imported_for.imports.order_by_recent.where(import_type: @import_type)
  end

  def create
    @import.status = :uploaded

    if @import.save
      @import.update(fields_mapping: NfgCsvImporter::FieldsMapper.new(@import).call)
      @import.service.maybe_set_import_number_of_records
      redirect_to edit_import_path(@import, mapped_column_count: @import.column_stats[:mapped_column_count])
    else
      render :action => 'new'
    end
  end

  def update
    import_params["fields_mapping"].each do |header_name, mapped_field_name|
      # The column headers are base64 encoded in _importer_column_header.html.haml
      # to prevent brackets and other special chars from causing issues with mapping.
      # See DM-4219 for more details.
      header_name = Base64.decode64(header_name)
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
    # mapped_column_count is passed as a param from the create action. All other cases it is nil
    @mapped_column_count = params[:mapped_column_count].to_i

    @first_x_rows = @import.first_x_rows
    render layout: (params[:iframe] ? 'full_width' : 'application')
  end

  def index
    @import = NfgCsvImporter::Import.new
    # if no pagination engine is available, just so the records
    @imports = @imported_for.imports.order_by_recent
    if defined?(WillPaginate)
      @imports = @imports.paginate(page: params[:page], per_page: 10)
    elsif defined?(Kaminari)
      @imports = @imports.page(params[:page]).per(10)
    end
  end

  def show
  end

  def destroy
    unless @import.can_be_deleted?(current_user)
      flash[:error] = t(:cannot_delete, scope: [:import, :destroy])
      return redirect_to import_path(@import)
    end

    if @import.uploaded?
      @import.destroy
      flash[:success] = t(:success_without_records, scope: [:import, :destroy])
    else # completed?
      number_of_records = @import.imported_records.size
      @import.update_attribute(:status, NfgCsvImporter::Import.statuses[:deleting])
      @import.imported_records.find_in_batches(batch_size: NfgCsvImporter::ImportedRecord.batch_size) do |batch|
        NfgCsvImporter::DestroyImportJob.perform_later(batch.map(&:id), @import.id)
      end
      flash[:success] = t(:success, number_of_records: number_of_records, scope: [:import, :destroy])
    end

    redirect_to imports_path
  end

  def template
    import_template_service = NfgCsvImporter::ImportTemplateService.new(import: @import, format: 'csv')
    send_data import_template_service.call, type: "text/csv", filename: "#{@import.import_type}_import_template.#{import_template_service.format}", disposition: 'attachment'
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
    @import ||= NfgCsvImporter::Import.queued.new(import_params.merge(import_type: @import_type, imported_for: @imported_for, imported_by: @imported_by))
  end

  def set_import_type
    redirect_to imports_path unless params[:import_type]
    @import_type ||= params[:import_type]
  end

  def authorize_user
    redirect_to imports_path unless @import.can_be_viewed_by(current_user)
  end

  def iframe_param_present?
    params[:iframe].present?
  end
end
