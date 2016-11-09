class NfgCsvImporter::ReviewsController < NfgCsvImporter::ApplicationController

  before_filter :load_imported_for
  before_filter :load_import, only: [:show]

  def show
  end
end
