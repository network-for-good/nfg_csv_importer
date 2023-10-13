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

  let(:import) { FactoryBot.build(:import, imported_for: entity, import_type: import_type, imported_by: admin, status: 'pending') }

  let(:import_file_validateable_host) { form }
  let(:params) { { import_file: file } }

  subject { import_file_validateable_host.validate(params) }

  context "validating the file" do
    it_behaves_like 'validate import file'
  end

  # the shared file above is used for import_spec as well
  # import.rb does its own validations by calling similar validations as upload-post_processing_form.rb
  # so the shared example works for both. However,
  # in this case we only want 20k max row limit on post_processing, so we are not adding 20k max row limit to import.rb
  context 'when number of rows is greater than the maximum number of rows allowed' do
    before { NfgCsvImporter.configuration.max_number_of_rows_allowed = 2 }
    after { NfgCsvImporter.configuration.max_number_of_rows_allowed = 50_000 }

    it "should add errors to base" do
      subject
      expect(import_file_validateable_host.errors.messages[:base].first).to eq I18n.t('nfg_csv_importer.onboarding.import_data.invalid_number_of_rows', num_rows: 2)
    end

    context 'when the file origination type is allowed to bypass the max row limit' do
      before { NfgCsvImporter.configuration.allowed_file_origination_types_to_bypass_max_row_limit = [import.file_origination_type.type_sym] }
      after { NfgCsvImporter.configuration.allowed_file_origination_types_to_bypass_max_row_limit = [] }

      it "should not add errors to base" do
        subject
        expect(import_file_validateable_host.errors.messages[:base]).to be_nil
      end
    end
  end

  context 'when number of rows is less than the maximum number of rows allowed' do
    before { NfgCsvImporter.configuration.max_number_of_rows_allowed = 10 }
    after { NfgCsvImporter.configuration.max_number_of_rows_allowed = 50_000 }

    it "should not add errors to base" do
      subject
      expect(import_file_validateable_host.errors.messages[:base]).to be_nil
    end
  end
end
