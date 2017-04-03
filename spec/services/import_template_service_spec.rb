require 'rails_helper'

describe NfgCsvImporter::ImportTemplateService do
  let(:format) { 'csv' }
  let(:template_service) { NfgCsvImporter::ImportTemplateService.new(import: import, format: format) }
  let(:import) { build(:import, imported_for: build_stubbed(:entity), import_type: :donation) }

  describe "#call" do
    subject { template_service.call }

    it "should have required columns" do
      expect(subject).to include "amount,donated_at"
    end

    it "should have optional columns" do
      expect(subject).to include 'amount,donated_at,description'
    end

    it "should have column descriptions" do
      expect(subject).to include "\nREQUIRED ,REQUIRED ,\"\"\n"
    end
  end
end
