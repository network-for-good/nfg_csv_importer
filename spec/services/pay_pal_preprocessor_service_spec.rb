require 'rails_helper'

describe PayPalPreprocessorService do
  include ActionDispatch::TestProcess

  let(:import) { FactoryGirl.create(:import,
                                  pre_processing_files: fixture_file_upload(File.open("spec/fixtures/PayPal_donations.xlsx")))}
  let(:service) { PayPalPreprocessorService.new(import) }

  describe '#process' do
    subject { service.process }

    it "should pre process and attach import_file" do
      subject
      import.reload
      expect(CSV.open(import.import_file.path).readlines).to eq  CSV.open('spec/fixtures/paypal_processed_file.csv').readlines
    end

    it "should store field mappings" do
      subject
      import.reload
      expect(import.fields_mapping).to eq service.send(:mapped_headers)
    end

    it "should set status to uploaded" do
      subject
      import.reload
      expect(import.status).to eq 'uploaded'
    end
  end
end
