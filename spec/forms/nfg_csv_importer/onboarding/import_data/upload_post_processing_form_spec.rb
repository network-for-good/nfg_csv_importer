require 'rails_helper'

describe NfgCsvImporter::Onboarding::ImportData::UploadPostProcessingForm  do
  let(:form) { described_class.new(import) }
  let(:entity) { create(:entity) }
  let(:import_type) { "users" }

  let(:file) do
    Rack::Test::UploadedFile.new("spec/fixtures#{file_name}", "mime/type")
  end

  let(:header_data) { ["email" ,"first_name","last_name"] }
  let(:file_name) { "/subscribers.csv" }
  let(:admin) {  create(:user) }

  let(:import) { FactoryGirl.build(:import, imported_for: entity, import_type: import_type, imported_by: admin, status: 'pending') }

  let(:import_file_validateable_host) { form }
  let(:params) { { import_file: file } }

  context "validating the file" do
    subject { import_file_validateable_host.validate(params) }

    it_behaves_like 'validate import file'
  end
end