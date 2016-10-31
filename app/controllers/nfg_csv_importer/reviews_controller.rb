class NfgCsvImporter::ReviewsController < NfgCsvImporter::ApplicationController
  def create
    render 'show'
  end
  alias_method :update, :create
end
