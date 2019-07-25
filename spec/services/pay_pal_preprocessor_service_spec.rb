require 'rails_helper'

describe PayPalPreprocessorService do
  include ActionDispatch::TestProcess

  let(:import) { FactoryGirl.create(:import, :pending,
                                    pre_processing_files: fixture_file_upload(File.open("spec/fixtures/#{file_name}")))}
  let(:service) { PayPalPreprocessorService.new(import) }

  describe '#process' do
    subject { service.process }

    context 'when the file is valid' do
      let(:file_name) { "PayPal_donations.xlsx" }

      it 'should pre process and attach import_file' do
        subject
        import.reload
        import_file_data = CSV.open(import.import_file.path).readlines
        processed_file_data = CSV.open('spec/fixtures/paypal_processed_file.csv').readlines
        expect(import_file_data).to eq processed_file_data
      end

      it 'should store field mappings' do
        subject
        import.reload
        headers = service.send(:mapped_headers_for_post_processing_file)
        expect(import.fields_mapping).to eq headers
      end

      it 'should set status' do
        subject
        import.reload
        expect(import.status).to eq 'uploaded'
      end

      it 'should set import_type' do
        subject
        import.reload
        expect(import.import_type).to eq 'individual_donation'
      end

      it 'should return a status object with the status value of success' do
        result = subject
        expect(result.status).to eq(:success)
      end
    end

    context "when the file is invalid" do
      let(:file_name) { "files/invalid_import.csv" }

      it 'returns a status object with error messages' do
        result = subject
        expect(result.status).to eq(:error)
        expect(result.errors).to be_present
      end
    end
  end
end
