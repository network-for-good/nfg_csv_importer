class NfgCsvImporter::ReviewsController < NfgCsvImporter::ApplicationController
  include NfgCsvImporter::Concerns::StatusChecks

  before_filter :load_imported_for
  before_filter :load_import
  before_filter :redirect_unless_uploaded_status

  def show
  end
end
