require "rails_helper"
# include Rails.application.routes.url_helpers
require 'nfg_csv_importer/file_origination_types/self_import_csv_xls'

describe NfgCsvImporter::Onboarder::Steps::NavigationBarPresenter do
  let(:h) { NfgCsvImporter::Onboarding::ImportDataController.new.view_context }
  let(:navigation_bar_presenter) { described_class.new(onboarding_session, h) }
  let(:onboarding_session) { NfgOnboarder::Session.new(name: 'import_data', current_step: current_step) }

  let(:steps) { [:first, :second, :last] }
  let(:current_step) { :first }

  before { h.expects(:controller).returns(stub(wizard_steps: steps)) }

  describe '#step_href(step, path)' do
    let(:path) { 'path/to/step' }

    subject { navigation_bar_presenter.step_href(current_step, path) }

    context 'when the supplied step is not the last step' do
      let(:current_step) { :first }
      it { is_expected.to eq path }
    end

    context 'when the supplied step is the last step' do
      let(:current_step) { :last }
      it { is_expected.to be_nil }
    end
  end

  describe '#step_icon(step)' do
    subject { navigation_bar_presenter.step_icon(current_step) }

    context 'when step is the last step' do
      let(:current_step) { :last }
      it { is_expected.to eq 'check' }
    end

    context 'when step is not the last step' do
      let(:current_step) { :first }
      it { is_expected.to be_nil }
    end
  end

  describe '#show_nav?' do
    before do
      h.expects(:params).returns(id: current_step)
    end

    subject { navigation_bar_presenter.show_nav? }

    context "when current step is the first" do
      let(:current_step) { :first }

      it 'will be false' do
        expect(subject).to be_falsey
      end
    end

    context "chen current step is not the first" do
      let(:current_step) { :second }

      it 'will be true' do
        expect(subject).to be_truthy
      end
    end
  end

  describe '#step_status(step)' do
    # before { h.expects(:params).returns(id: current_step) }

    # subject { navigation_bar_presenter.step_status(tested_step) }

    # context 'when the tested step is the active step' do
    #   let(:tested_step) { current_step }
    #   it { is_expected.to eq :active }

    # end
  end
end