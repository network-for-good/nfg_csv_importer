class NfgCsvImporter::ReviewsController < NfgCsvImporter::ApplicationController
  include NfgCsvImporter::Concerns::StatusChecks

  before_action :load_imported_for, only: [:show]
  before_action :load_import, only: [:show]
  before_action :redirect_unless_uploaded_status, only: [:show]

  def show
  end

  def preview
  end
end
