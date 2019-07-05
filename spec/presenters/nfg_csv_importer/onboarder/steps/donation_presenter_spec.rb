require "rails_helper"
# include Rails.application.routes.url_helpers
require 'nfg_csv_importer/file_origination_types/self_import_csv_xls'

describe NfgCsvImporter::Onboarder::Steps::DonationPresenter do
  let(:h) { NfgCsvImporter::Onboarding::ImportDataController.new.view_context }
  let(:preview_confirmation_presenter) { described_class.new(onboarding_session, h) }
  let(:onboarding_session) { NfgOnboarder::Session.new(name: 'import_data', current_step: current_step, step_data: step_data) }
  let(:file_origination_type) { NfgCsvImporter::FileOriginationTypes::FileOriginationType.new(tested_type_sym, NfgCsvImporter::FileOriginationTypes::SelfImportCsvXls) }
  let(:tested_type_sym) { :self_import_csv_xls }

  let(:current_step) { 'preview_confirmation' }

  let(:type_sym) { file_origination_type.type_sym }

  let(:step_data) { {"import_data" => {file_origination_type_selection: ActionController::Parameters.new('file_origination_type' => type_sym)}} }

  let(:campaign) { 'My awesome campaign' }
  let(:donated_at) { '06/03/2019' }
  let(:amount) { '20.00' }
  let(:transaction_id) { '12334343' }
  let(:note) { 'some note' }
  let(:rows_to_render) do
    [
      {
       "gross" => amount, "donated_at" => donated_at, "payment_method" => "credit_card",
       "campaign" => campaign, "transaction_id" => transaction_id, "user_notes" => note
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

  describe "#humanized_card_header_icon" do

    subject { preview_confirmation_presenter.humanized_card_header_icon }

    let(:icon) {'dollar'}
    it { is_expected.to eq 'dollar' }
  end

  describe '#humanized_card_heading' do
    before do
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:rows_to_render).returns(rows_to_render)
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:nfg_csv_importer_to_host_mapping).returns(nfg_csv_importer_to_host_mapping)
    end

    subject {preview_confirmation_presenter.humanized_card_heading}

    it { is_expected.to eq amount }

    it_behaves_like 'when there is not sufficient data', ""
  end

  describe '#humanized_card_heading_caption' do

    before do
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:rows_to_render).returns(rows_to_render)
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:nfg_csv_importer_to_host_mapping).returns(nfg_csv_importer_to_host_mapping)
    end

    subject {preview_confirmation_presenter.humanized_card_heading_caption}

    it_behaves_like 'when there is not sufficient data', ["", ""]

    it { is_expected.to eq [campaign, donated_at] }
  end

  describe '#humanized_card_body' do

    before do
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:rows_to_render).returns(rows_to_render)
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:nfg_csv_importer_to_host_mapping).returns(nfg_csv_importer_to_host_mapping)
    end

    subject {preview_confirmation_presenter.humanized_card_body}

    let(:response) { [{transaction_id: [transaction_id]}, {note: [note]}] }
    it_behaves_like 'when there is not sufficient data', [{:transaction_id => [""]}, {:note => [""]}]

    it { is_expected.to eq response }
  end

end
