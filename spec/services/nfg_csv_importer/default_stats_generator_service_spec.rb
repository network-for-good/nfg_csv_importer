require 'rails_helper'
require 'roo'

RSpec.describe NfgCsvImporter::DefaultStatsGeneratorService do
  let(:default_stats_generator) do
    NfgCsvImporter::DefaultStatsGeneratorService.new(spreadsheet: spreadsheet,
                                                  row_conversion_method: row_conversion_method)
  end

  let(:spreadsheet) { mock('spreadsheet') }
  let(:data) { 'some-data' }
  let(:another_data) { 'another-data' }
  let(:row_conversion_method) { mock('method') }
  let(:response) do
    {
      "summary_data" => { "number_of_rows" => 9 },
      "example_rows" => [ data, another_data ]
    }
  end

  before { spreadsheet.expects(:last_row).returns(10) }

  describe '#call' do
    subject { default_stats_generator.call }

    context 'when the row conversion method exists' do
      before do
        row_conversion_method.expects(:call).with(2).returns(data)
        row_conversion_method.expects(:call).with(4).returns(another_data)
      end

      it { is_expected.to eq response }
    end


    context 'when the row converesion method is nil' do
      let(:row_conversion_method) { nil }
      let(:response) do
        {
          "summary_data" => { "number_of_rows" => 9 },
          "example_rows" => [ nil, nil ]
        }
      end

      it { is_expected.to eq response }
    end
  end
end
