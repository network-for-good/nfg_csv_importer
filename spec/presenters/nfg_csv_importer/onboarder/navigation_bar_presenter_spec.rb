require "rails_helper"
# include Rails.application.routes.url_helpers
require 'nfg_csv_importer/file_origination_types/self_import_csv_xls'

describe NfgCsvImporter::Onboarder::Steps::NavigationBarPresenter do
  let(:h) { NfgCsvImporter::Onboarding::ImportDataController.new.view_context }
  let(:navigation_bar_presenter) { described_class.new(onboarding_session, h) }
  let(:onboarding_session) { NfgOnboarder::Session.new(name: 'import_data', current_step: current_step, step_data: step_data) }
  let(:file_origination_type) { NfgCsvImporter::FileOriginationTypes::FileOriginationType.new(tested_type_sym, NfgCsvImporter::FileOriginationTypes::SelfImportCsvXls) }
  let(:tested_type_sym) { :self_import_csv_xls }


  let(:type_sym) { file_origination_type.type_sym }

  let(:step_data) { { "import_data" => { file_origination_type_selection: ActionController::Parameters.new('file_origination_type' => type_sym) } } }

  it { expect(described_class).to be < NfgCsvImporter::Onboarder::OnboarderPresenter }

  describe '#show_nav?' do
    before do
      h.expects(:controller).returns(stub(wizard_steps: steps))
      h.expects(:params).returns(id: current_step)
    end
    let(:steps) { [:first, :second, :third] }

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
end