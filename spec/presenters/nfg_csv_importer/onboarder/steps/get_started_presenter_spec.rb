require "rails_helper"
# include Rails.application.routes.url_helpers
require 'nfg_csv_importer/file_origination_types/self_import_csv_xls'

describe NfgCsvImporter::Onboarder::Steps::GetStartedPresenter do
  let(:h) { NfgCsvImporter::Onboarding::ImportDataController.new.view_context }
  let(:get_started_presenter) { described_class.new(onboarding_session, h) }
  let(:onboarding_session) { NfgOnboarder::Session.new(name: 'import_data', current_step: current_step, step_data: step_data) }
  let(:file_origination_type) { NfgCsvImporter::FileOriginationTypes::FileOriginationType.new(tested_type_sym, NfgCsvImporter::FileOriginationTypes::SelfImportCsvXls) }
  let(:tested_type_sym) { :self_import_csv_xls }

  let(:current_step) { 'get_started' }

  let(:type_sym) { file_origination_type.type_sym }

  let(:step_data) { { "import_data" => { file_origination_type_selection: ActionController::Parameters.new('file_origination_type' => type_sym) } } }

  it { expect(described_class).to be < NfgCsvImporter::Onboarder::OnboarderPresenter }

  describe '#get_started_information_step(step:)' do
    let(:step) { 1 }
    subject { get_started_presenter.get_started_information_step(step: step) }

    it 'outputs the correct I18n entry with the options present' do
      expect(subject).to include h.ui.nfg(:typeface,
              heading: I18n.t("nfg_csv_importer.onboarding.import_data.get_started.body.step1.heading", file_origination_type: type_sym.to_s)).gsub("'", '&#39;')

      expect(subject).to include h.ui.nfg(:typeface,
             body: I18n.t("nfg_csv_importer.onboarding.import_data.get_started.body.step1.body")).gsub("'", '&#39;')
    end
  end

  describe '#get_started_information_step_image(step:)' do
    let(:tested_step) { 1 }
    let(:step) { tested_step }
    subject { get_started_presenter.get_started_information_step_image(step: step) }

    it { is_expected.to eq h.image_tag "nfg_csv_importer/illustrations/get-started-step#{tested_step}.png" }
  end

  describe '#show_time_estimate?' do
    pending 'not yet working'
    # subject { get_started_presenter.show_time_estimate? }

    # context 'when the import file_origination_type is not a third-party' do
    #   # let(:tested_type_sym) { :self_import_csv_xls }
    #   let(:type_sym) { :self_import_csv_xls }
    #   before { get_started_presenter.stubs(:file_origination_type).returns(file_origination_type) }

    #   # let(:type_sym) { tested_type_sym }
    #   it { is_expected.not_to be }
    # end

    # context 'when the import file_origination_type is a third-party' do
    #   # before { get_started_presenter.stubs(:file_origination_type).returns(file_origination_type) }
    #   let(:type_sym) { :paypal }
    #   it { is_expected.to be }
    # end
  end

  describe '#external_resource_url' do
    pending 'not yet working'
    # subject { get_started_presenter.external_resource_url }
    # let(:file_origination_type) { NfgCsvImporter::FileOriginationTypes::FileOriginationType.new(:self_import_csv_xls, FileOriginationTypes::SelfImportCsvXls) }
    # let(:type_sym) { NfgCsvImporter::FileOriginationTypes::FileOriginationType.new(:self_import_csv_xls, FileOriginationTypes::SelfImportCsvXls) }
    # # before { get_started_presenter.stubs(:file_origination_type).returns(file_origination_type) }
    # it { is_expected.to eq I18n.t("nfg_csv_importer.urls.knowledge_base.walk_throughs.file_origination_types.#{file_origination_type}") }
  end
end