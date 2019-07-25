class NfgCsvImporter::AttachmentsController < NfgCsvImporter::ApplicationController

  def destroy
    blob = ActiveStorage::Blob.find_signed(params[:id])
    blob.attachments.map(&:purge)
    # blob.purge_later
    head :no_content
  end

end
