require 'rails_helper'

describe PayPalPreprocessorService do
  include ActionDispatch::TestProcess

  let(:import) { FactoryGirl.create(:import,
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
      headers =  %w{address address_2 amount city country description donated_at email home_phone name payment_method state transaction_id zip_code}
      expect(import.fields_mapping).to eq Hash[headers.collect { |v| [v.to_s, v.to_s] }]
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
  end
end
