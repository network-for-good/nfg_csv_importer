require 'rails_helper'

describe NfgCsvImporter::ImportTemplateService do
  let(:format) { 'csv' }
  let(:template_service) { NfgCsvImporter::ImportTemplateService.new(import: import, format: format) }
  let(:import) { build(:import, imported_for: build_stubbed(:entity)) }

  describe "#call" do
    subject { template_service.call }

    it "should have required columns" do
      expect(subject).to include "email"
    end

    it "should have optional columns" do
      expect(subject).to include 'first_name,last_name,full_name'
    end

    it "should have column descriptions" do
      expect(subject).to include "\nREQUIRED ,\"\",\"\",\"\"\n"
    end
  end
end
