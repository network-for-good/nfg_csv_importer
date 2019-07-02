require 'rails_helper'

describe PayPalPreprocessorService do
  include ActionDispatch::TestProcess

  let(:import) { FactoryGirl.create(:import, :pending,
                                    pre_processing_files: fixture_file_upload(File.open('spec/fixtures/PayPal_donations.xlsx')))}
  let(:service) { PayPalPreprocessorService.new(import) }

  describe '#process' do
    subject { service.process }

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

    it 'should set status to uploaded' do
      subject
      import.reload
      expect(import.status).to eq 'uploaded'
    end
  end
end
