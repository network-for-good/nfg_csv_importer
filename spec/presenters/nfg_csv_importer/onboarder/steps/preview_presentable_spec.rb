require "rails_helper"
# include Rails.application.routes.url_helpers
require 'nfg_csv_importer/file_origination_types/self_import_csv_xls'

describe 'NfgCsvImporter::PreviewPresentable' do
  let(:h) { NfgCsvImporter::Onboarding::ImportDataController.new.view_context }
  let(:user_class) { NfgCsvImporter::Onboarder::Steps::UserPresenter }
  let(:user_presenter) { user_class.new(onboarding_session, h) }
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
  let(:rows_to_render) do
    [
      {
        "payment_method" => "credit_card",
        "first_name" => first_name, "last_name" => last_name, "email" => email,
        "address" => address, "address_2" => address_2, "city" => city,
        "state" => state, "zip_code" => zip_code, "home_phone" => phone
      }
    ]
  end
  let(:nfg_csv_importer_to_host_mapping) do
    {
      "amount" => 'gross', "email" => 'email', "address" => 'address', "first_name" => 'first_name', "last_name" => 'last_name',
      "email" => 'email', "phone" => 'home_phone', "address" => 'address', "address_2" => 'address_2', "city" => 'city', "state" => 'state',
      "zip_code" => 'zip_code', "note" => 'user_notes', "transaction_id" => 'transaction_id', "donated_at" => 'donated_at', "campaign" => 'campaign'
    }
  end

  before { h.stubs(:import).returns(mock('import')) }

  describe "#humanized_card_body_icon" do
    let(:keyword) { 'address' }

    before do
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:rows_to_render).returns(rows_to_render)
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:nfg_csv_importer_to_host_mapping).returns(nfg_csv_importer_to_host_mapping)
    end

    subject { user_presenter.humanized_card_body_icon(keyword) }

    it { is_expected.to eq 'home' }

    context 'when address is nil' do
      let(:address) { nil }

      it { is_expected.to eq '' }
    end

    context 'when keyword is unrecognized' do
      let(:keyword) { 'some-keyword' }

      it { is_expected.to eq 'circle inverse' }
    end
  end

end
