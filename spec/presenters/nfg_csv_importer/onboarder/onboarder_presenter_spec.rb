require "rails_helper"

describe NfgCsvImporter::Onboarder::OnboarderPresenter do
  let(:h) { NfgCsvImporter::Onboarding::ImportDataController.new.view_context }
  let(:onboarding_session) { FactoryGirl.create(:onboarding_session, *traits) }
  let(:traits) { [:"#{current_step}_step"] } # auto-generate the correct onboarding session step
  let(:current_step) { 'file_origination_type_selection' }
  let(:onboarder_presenter) { described_class.new(onboarding_session, h) }

  it { expect(described_class).to be < NfgCsvImporter::GemPresenter }

  before { h.controller.stubs(:params).returns(id: current_step) }

  describe '#build(model, view, options = {})' do
    let(:options) { { arbitrary_option: :value } }
    let(:current_step) { 'file_origination_type_selection' }
    subject { described_class.build(onboarding_session, h, options) }

    it 'initializes the correct OnboarderPresenter' do
      expect(subject.class.name).to eq "NfgCsvImporter::Onboarder::Steps::#{current_step.camelize}Presenter"
    end
  end

  describe '#color_theme(humanize)' do
    subject { onboarder_presenter.color_theme(humanize) }

    context 'when :humanize is user' do
      let(:humanize) { 'user' }
      it { is_expected.to eq :primary }
    end

    context 'when :humanize is donation' do
      let(:humanize) { 'donation' }
      it { is_expected.to eq :success }
    end
  end

  describe '#file_origination_type_name' do
    subject { onboarder_presenter.file_origination_type_name }
    context "when step_data['import_data'] is present" do
      let(:traits) { [:paypal_file_origination_type] }

      it 'returns the name of the file origination type' do
        expect(subject).to eq 'paypal'
      end
    end

    context "when step_data['import_data'] is not present" do
      let(:traits) { [:without_step_data] }

      it 'returns an empty string' do
        expect(subject).to eq ''
      end
    end
  end

  describe '#file_origination_type' do
    subject { onboarder_presenter.file_origination_type }
    context 'when a Paypal File Origination type' do
      let(:traits) { [:paypal_file_origination_type] }
      it 'is the PayPal file origination type' do
        expect(subject.type_sym).to eq :paypal
      end
    end

    context 'when not PayPal file origination type' do
      let(:traits) { [:self_import_csv_xls_file_origination_type] }
      it 'is the SelfImport CSV XLS file origination type' do
        expect(subject.type_sym).to eq :self_import_csv_xls
      end
    end
  end

  describe '#file_origination_types' do
    let(:types_symbol_array) { NfgCsvImporter::FileOriginationTypes::Manager.new(NfgCsvImporter.configuration).types.collect(&:type_sym) }
    subject { onboarder_presenter.file_origination_types }

    it 'returns the correct types evaluated by checking their type_sym value' do
      expect(subject.collect(&:type_sym)).to eq types_symbol_array
    end
  end

  describe '#on_first_step?' do
    before { h.controller.stubs(:first_step).returns(on_first_step) }
    subject { onboarder_presenter.on_first_step? }

    context 'when on the first step' do
      let(:on_first_step) { true }
      it { is_expected.to be }
    end

    context 'when not on the first step' do
      let(:on_first_step) { false }
      it { is_expected.not_to be }
    end
  end

  # Flimsy spec, but ensures the method works
  describe '#first_step' do
    subject { onboarder_presenter.first_step }
    # Stub the actual values
    before { h.controller.stubs(:wizard_steps).returns(NfgCsvImporter::Onboarding::ImportDataController.step_list) }

    it { is_expected.to eq :file_origination_type_selection }
  end

  # Flimsy spec, but ensures the method works
  describe '#active_step' do
    subject { onboarder_presenter.active_step }
    before { h.controller.stubs(:params).returns(id: current_step) }
    it { is_expected.to eq current_step }
  end
end