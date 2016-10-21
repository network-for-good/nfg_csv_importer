require 'rails_helper'

describe NfgCsvImporter::ImportsHelper do
  describe "#index_alphabetize" do
    it "returns alphabetic characters" do
      { 0 => 'A', 1 => 'B', 26 => 'AA' }.each do |index, value|
        expect(helper.index_alphabetize[index]).to eq value
      end
    end
  end
end
