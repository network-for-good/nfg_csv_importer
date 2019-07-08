require "rails_helper"
# include Rails.application.routes.url_helpers
require 'nfg_csv_importer/file_origination_types/self_import_csv_xls'

describe NfgCsvImporter::Onboarder::Steps::UserSupplementPresenter do
  let(:h) { NfgCsvImporter::Onboarding::ImportDataController.new.view_context }
  let(:preview_confirmation_presenter) { described_class.new(onboarding_session, h) }
  let(:onboarding_session) { NfgOnboarder::Session.new(name: 'import_data', current_step: current_step, step_data: step_data) }
  let(:file_origination_type) { NfgCsvImporter::FileOriginationTypes::FileOriginationType.new(tested_type_sym, NfgCsvImporter::FileOriginationTypes::SelfImportCsvXls) }
  let(:tested_type_sym) { :self_import_csv_xls }

  let(:current_step) { 'preview_confirmation' }

  let(:type_sym) { file_origination_type.type_sym }

  let(:step_data) { {"import_data" => {file_origination_type_selection: ActionController::Parameters.new('file_origination_type' => type_sym)}} }

  let(:phone) { '1111111111' }
  let(:email) { 'awesome@example.com' }
  let(:first_name) { 'Awesome' }
  let(:last_name) { 'Name' }
  let(:address) { '80 Rice Ave' }
  let(:address_2) { '#201' }
  let(:city) { 'San Francisco' }
  let(:state) { 'CA' }
  let(:zip_code) { '95991' }
  let(:job_title) { 'Football Player' }
  let(:employer) { 'Amazing football league' }
  let(:dob_month) { '6' }
  let(:dob_year) { '1990' }
  let(:dob_day) { '12' }
  let(:date_of_birth) { nil }
  let(:rows_to_render) do
    [
      {
        "payment_method" => "credit_card",
        "first_name" => first_name, "last_name" => last_name, "email" => email,
        "address" => address, "address_2" => address_2, "city" => city,
        "state" => state, "zip_code" => zip_code, "home_phone" => phone,
        "job_title" => job_title, "employer" => employer, "dob_month" => dob_month,
        "dob_day" => dob_day, "dob_year" => dob_year, "date_of_birth" => date_of_birth
      }
    ]
  end
  let(:nfg_csv_importer_to_host_mapping) do
    {
      job_title: 'job_title', employer: 'employer', gender: 'gender',
      dob_year: 'dob_year', dob_month: 'dob_month', dob_day: 'dob_day',
      date_of_birth: 'date_of_birth'
    }
  end

  it { expect(described_class).to be < NfgCsvImporter::Onboarder::Steps::PreviewConfirmationPresenter }

  before { h.stubs(:import).returns(mock('import')) }

  shared_examples_for 'when there is not sufficient data' do |result|
    context 'when there are no rows to render' do
      let(:rows_to_render) { [] }
      it { is_expected.to eq result }
    end

    context 'when there are no stats keys' do
      let(:nfg_csv_importer_to_host_mapping) { {} }
      it { is_expected.to eq result }
    end
  end

  describe "#humanized_card_header_icon" do

    subject { preview_confirmation_presenter.humanized_card_header_icon }

    it { is_expected.to eq 'user' }
  end

  describe '#humanized_card_heading' do

    before do
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:rows_to_render).returns(rows_to_render)
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:nfg_csv_importer_to_host_mapping).returns(nfg_csv_importer_to_host_mapping)
    end

    subject { preview_confirmation_presenter.humanized_card_heading }

    it { is_expected.to eq job_title }

    it_behaves_like 'when there is not sufficient data', ""
  end

  describe '#humanized_card_heading_caption' do

    before do
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:rows_to_render).returns(rows_to_render)
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:nfg_csv_importer_to_host_mapping).returns(nfg_csv_importer_to_host_mapping)
    end

    subject { preview_confirmation_presenter.humanized_card_heading_caption }

    it_behaves_like 'when there is not sufficient data', [""]

    it { is_expected.to eq [employer] }
  end

  describe '#humanized_card_body' do

    before do
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:rows_to_render).returns(rows_to_render)
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:nfg_csv_importer_to_host_mapping).returns(nfg_csv_importer_to_host_mapping)
    end

    subject { preview_confirmation_presenter.humanized_card_body }

    let(:response) { [{ date_of_birth: ["#{dob_month}/#{dob_day}/#{dob_year}"] }] }

    it_behaves_like 'when there is not sufficient data', [{ :date_of_birth => [""] }]

    context 'when there is full date of birth' do
      let(:dob_month) { nil }
      let(:dob_year) { nil }
      let(:dob_day) { nil }
      let(:date_of_birth) { '05/03/2010' }

      let(:response) { [{ date_of_birth: ["#{date_of_birth}"] }] }

      it { is_expected.to eq response }
    end

    it { is_expected.to eq response }
  end

end
