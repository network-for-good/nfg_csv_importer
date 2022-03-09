require 'rails_helper'

RSpec.describe NfgCsvImporter::BaseStatsGeneratorService do
  let(:base_stats_generator) do
    NfgCsvImporter::BaseStatsGeneratorService.new(spreadsheet: spreadsheet,
                                                  row_conversion_method: row_conversion_method)
  end

  let(:spreadsheet) { mock('spreadsheet') }
  let(:row_conversion_method) { mock(' conversation method')}


  describe '#call' do
    subject { base_stats_generator.call }

    it { is_expected.to raise_exception rescue nil }
  end
end
