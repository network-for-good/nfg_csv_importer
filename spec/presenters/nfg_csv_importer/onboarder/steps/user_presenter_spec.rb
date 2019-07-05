require "rails_helper"
# include Rails.application.routes.url_helpers
require 'nfg_csv_importer/file_origination_types/self_import_csv_xls'

describe NfgCsvImporter::Onboarder::Steps::UserPresenter do
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


  let(:stats) do
    {
      "total_amount" => total_amount, "num_addresses" => num_addresses, "num_emails" => num_emails,
      "total_contacts" => total_contacts,
      "zero_amount_donations" => zero_amount_donations, "non_zero_amount_donations" => non_zero_amount_donations
    }.to_json
  end

  it { expect(described_class).to be < NfgCsvImporter::Onboarder::OnboarderPresenter }

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

  shared_examples_for 'when import statistics are not available' do |result|
    context 'when import statistics are nil' do
      let(:stats) { nil }
      it { is_expected.to eq result }
    end

    context 'when import statistics do not have the right keys' do
      let(:stats) { {}.to_json }
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

    let(:name) { "#{first_name} #{last_name}" }

    it { is_expected.to eq name }

    it_behaves_like 'when there is not sufficient data', ""
  end

  describe '#humanized_card_heading_caption' do

    before do
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:rows_to_render).returns(rows_to_render)
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:nfg_csv_importer_to_host_mapping).returns(nfg_csv_importer_to_host_mapping)
    end

    subject { preview_confirmation_presenter.humanized_card_heading_caption }

    it_behaves_like 'when there is not sufficient data', ["", ""]

    it { is_expected.to eq [phone, email] }
  end

  describe '#humanized_card_body' do

    before do
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:rows_to_render).returns(rows_to_render)
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:nfg_csv_importer_to_host_mapping).returns(nfg_csv_importer_to_host_mapping)
    end

    subject { preview_confirmation_presenter.humanized_card_body }

    let(:response) { [{ address: [address, address_2, "#{city}, #{state} #{zip_code}", 'USA'] }] }
    it_behaves_like 'when there is not sufficient data', [ { :address => ["", "", ",  ", "USA"] } ]

    it { is_expected.to eq response }
  end

end
