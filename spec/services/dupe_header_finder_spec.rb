require 'rails_helper'

RSpec.describe NfgCsvImporter::DupeHeaderFinder do
  let(:header_finder) { described_class.new(headers) }
  let(:headers) { ["First Name", "email", "first_name", "last_name", "first name", "address"] }

  describe '#call' do
    subject { header_finder.call }
    context 'when the list of headers contains duplicates' do
      # we consider the following duplicates "first_name" "First Name" "first name"

      it 'should return a hash where the formatted header is the key and the value is an array of matching headers and their position (starting with 0)' do
        expect(subject).to eq({"first_name"=>[["First Name", 0], ["first_name", 2], ["first name", 4]]})
      end
    end

    context 'when the list of headers does not contain any duplicates' do
      let(:headers) { ["email", "first_name", "last_name", "address"] }

      it 'should return an empty hash' do
        expect(subject).to eq({})
      end
    end

    context 'when the list of headers contain multiple duplicates' do
      let(:headers) { ["First Name", "email", "first_name", "last_name", "last name", "address"] }

      it 'should return a hash where the formatted header is the key and the value is an array of matching headers and their position (starting with 0)' do
        expect(subject).to eq({"first_name"=>[["First Name", 0], ["first_name", 2]],
                               "last_name" => [["last_name", 3], ["last name", 4]]})
      end
    end

    context "when one or more of the columns is empty" do
      let(:headers) { ["", "last name", "", "Last Name", "email"] }

      it 'should ignore those columns' do
        expect(subject).to eq({"last_name" => [["last name", 1], ["Last Name", 3]]})
      end
    end
  end
end