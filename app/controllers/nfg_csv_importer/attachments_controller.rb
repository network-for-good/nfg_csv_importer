class NfgCsvImporter::AttachmentsController < NfgCsvImporter::ApplicationController
  def destroy
    blob = ActiveStorage::Blob.find_signed(params[:id])
    blob.attachments.map(&:purge)
    head :no_content
  end
end
