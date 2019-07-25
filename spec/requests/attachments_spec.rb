require "rails_helper"

RSpec.describe "ActiveStorage Attachments", type: :request do
  let(:blob_id) { import.pre_processing_files.first.blob.signed_id }
  let!(:import) { create(:import, :with_pre_processing_files, status: 'uploaded', import_file: File.open("spec/fixtures/individual_donation.csv" )) }

  it "deletes attachments and blob records" do
    expect do
      delete "/nfg_csv_importer/attachments/#{blob_id}"
    end.to change(ActiveStorage::Blob, :count).by(-1)
    .and change(ActiveStorage::Attachment, :count).by(-1)
  end
end
