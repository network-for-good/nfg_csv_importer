require 'rails_helper'

describe NfgCsvImporter::ImportsHelper do
  describe "#index_alphabetize" do
    it "returns alphabetic characters" do
      { 0 => 'A', 1 => 'B', 26 => 'AA' }.each do |index, value|
        expect(helper.index_alphabetize[index]).to eq value
      end
    end
  end

  describe "#is_browser_a_touch_device?" do
    subject { helper.is_browser_a_touch_device? }

    it { expect(subject).not_to be }

    context "when the device is mobile" do
      before { Browser.any_instance.stubs(:mobile?).returns(true) }

      it { expect(subject).to be }
    end

    context "when the device is tablet" do
      before { Browser.any_instance.stubs(:tablet?).returns(true) }

      it { expect(subject).to be }
    end
  end

  describe "#bootstrap_tooltip" do
    subject { helper.bootstrap_tooltip(tooltip_content, placement) }
    let(:tooltip_content) { 'Test' }
    let(:placement) { :top }

    context "when placement is not acceptable" do
      let(:placement) { :top_right }

      it { expect { subject }.to raise_exception(StandardError) }
    end

    context "when device is touch device" do
      before { helper.stubs(:is_browser_a_touch_device?).returns(true) }

      it { expect(subject).to be_empty }
    end

    context "when device is not touch device" do
      it { expect(subject).to eq({ title: "Test",  data: { placement: :top, toggle: "tooltip"} }) }
    end
  end

  describe "#number_of_records_without_errors_based_on_import_status" do
    subject { helper.number_of_records_without_errors_based_on_import_status(import) }
    let(:import) { build_stubbed(:import, status: status, number_of_records: 4) }
    let(:status) { :processing }

    context "when status is :uploaded" do
      let(:status) { :uploaded }

      it { expect(subject).to eq "<i class=\"fa fa-minus text-muted\"></i>" }
    end

    it { expect(subject).to eq "<h4>4</h4>" }
  end

  describe "#number_of_records_with_errors_based_on_import_status" do
    subject { helper.number_of_records_with_errors_based_on_import_status(import) }
    let(:import) { build_stubbed(:import, status: status, number_of_records: 4, number_of_records_with_errors: error_records_count) }
    let(:error_records_count) { 0 }
    let(:status) { :uploaded }

    context "when imported with errors" do
      let(:error_records_count) { 2 }

      context "when status is :processing" do
        let(:status) { :processing }

        it { expect(subject).to match("Error File") }
        it { expect(subject).to match("text-muted") }
      end

      context "when status is not :processing" do
        let(:file) { File.open("spec/fixtures/subscribers.csv")}
        let(:import) { build_stubbed(:import, status: status, error_file: file, number_of_records: 4, number_of_records_with_errors: error_records_count) }

        it { expect(subject).to match("text-danger") }
        it { expect(subject).to match("Error File") }
      end

    end

    it { expect(subject).to eq "<i class=\"fa fa-minus text-muted\"></i>" }
  end

  describe "#import_status_link" do
    subject { helper.import_status_link(import) }
    before { helper.stubs(:import_path).returns("/imports") }
    let(:import) { build_stubbed(:import, status: status, number_of_records: 4) }
    let(:status) { }

    context "when status is :uploaded" do
      let(:status) { :uploaded }

      it { expect(subject).to match("gear") }
      it { expect(subject).to match("Review &amp; Mapping") }
    end

    context "when status is :defined" do
      let(:status) { :defined }

      it { expect(subject).to match("table") }
    end

    context "when status is :queued" do
      let(:status) { :queued }

      it { expect(subject).to match("hourglass-2") }
      it { expect(subject).to match("text-warning") }
    end

    context "when status is :processing" do
      let(:status) { :processing }

      it { expect(subject).to match("refresh") }
      it { expect(subject).to match("text-warning") }
    end

    context "when status is :complete" do
      let(:status) { :complete }

      it { expect(subject).to match("check") }
      it { expect(subject).to match("text-success") }

    end

    context "when status is :deleting" do
      let(:status) { :deleting }

      it { expect(subject).to match("trash-o") }
      it { expect(subject).to match("text-danger") }
    end

    context "when status is :deleted" do
      let(:status) { :deleted }

      it { expect(subject).to match("trash-o") }
      it { expect(subject).to match("text-danger") }
    end

  end
end
