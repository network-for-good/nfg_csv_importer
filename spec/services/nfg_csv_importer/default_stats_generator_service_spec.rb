require 'rails_helper'
require 'roo'

RSpec.describe NfgCsvImporter::DefaultStatsGeneratorService do
  let(:default_stats_generator) do
    NfgCsvImporter::DefaultStatsGeneratorService.new(spreadsheet: spreadsheet,
                                                  row_conversion_method: row_conversion_method)
  end

  let(:spreadsheet) { (1..10).to_a }
  let(:data) { 'some-data' }
  let(:another_data) { 'another-data' }
  let(:row_conversion_method) { -> (i) { spreadsheet[1] } }
  let(:number_of_rows) { spreadsheet.length - 1 } # we don't count the first row, which holds the header info
  let(:response) do
    {
      "summary_data" => { "number_of_rows" => number_of_rows },
      "example_rows" => [ data, another_data ]
    }
  end

  before do
    spreadsheet.expects(:last_row).at_least(1).returns(spreadsheet.length)
    # Random.expects(:new).returns(mock(rand: 7))
  end

  describe '#call' do
    subject { default_stats_generator.call }

    context 'when the row conversion method exists' do
      before do
        row_conversion_method.expects(:call).twice.with(any_of(*(1..10).to_a)).returns(data, another_data)
      end

      it { is_expected.to eq response }
    end


    context 'when the row converesion method is nil' do
      let(:row_conversion_method) { nil }
      let(:response) do
        {
          "summary_data" => { "number_of_rows" => number_of_rows },
          "example_rows" => [ nil, nil ]
        }
      end

      it { is_expected.to eq response }
    end
  end
end
