class NfgCsvImporter::ReviewsController < NfgCsvImporter::ApplicationController
  include NfgCsvImporter::Concerns::StatusChecks

  before_action :load_imported_for
  before_action :load_import
  before_action :redirect_unless_uploaded_status

  def show
  end
end
