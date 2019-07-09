require "rails_helper"
# include Rails.application.routes.url_helpers
require 'nfg_csv_importer/file_origination_types/self_import_csv_xls'

describe NfgCsvImporter::Onboarder::Steps::PreviewConfirmationPresenter do
  let(:h) { NfgCsvImporter::Onboarding::ImportDataController.new.view_context }
  let(:preview_confirmation_presenter) { described_class.new(onboarding_session, h) }
  let(:onboarding_session) { NfgOnboarder::Session.new(name: 'import_data', current_step: current_step, step_data: step_data) }
  let(:file_origination_type) { NfgCsvImporter::FileOriginationTypes::FileOriginationType.new(tested_type_sym, NfgCsvImporter::FileOriginationTypes::SelfImportCsvXls) }
  let(:tested_type_sym) { :self_import_csv_xls }

  let(:current_step) { 'preview_confirmation' }

  let(:type_sym) { file_origination_type.type_sym }

  let(:step_data) { { "import_data" => { file_origination_type_selection: ActionController::Parameters.new('file_origination_type' => type_sym) } } }

  let(:phone) { '1111111111' }
  let(:email) { 'awesome@example.com' }
  let(:campaign) { 'My awesome campaign' }
  let(:donated_at) { '06/03/2019' }
  let(:first_name) { 'Awesome' }
  let(:last_name) { 'Name' }
  let(:amount) { '20.00' }
  let(:address) { '80 Rice Ave' }
  let(:address_2) { '#201' }
  let(:city) { 'San Francisco' }
  let(:state) { 'CA' }
  let(:zip_code) { '95991' }
  let(:transaction_id) { '12334343' }
  let(:note) { 'some note' }
  let(:rows_to_render) do
    [
      {"gross"=> amount, "donated_at"=>donated_at, "payment_method"=>"credit_card",
       "first_name"=> first_name, "last_name"=> last_name, "email"=>email,
       "address"=> address, "address_2"=>address_2, "city"=>city,
       "state"=>state, "zip_code"=>zip_code, "home_phone" => phone, "campaign" => campaign,
       "transaction_id" => transaction_id, "user_notes" => note
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

  let(:total_contacts) { 10 }
  let(:total_amount) { 30 }
  let(:num_addresses) { 2 }
  let(:num_emails) { 5 }
  let(:zero_amount_donations) { 15 }
  let(:non_zero_amount_donations) { 15 }
  let(:stats) do
    {
      "total_amount"=>total_amount, "num_addresses"=>num_addresses, "num_emails"=>num_emails,
      "total_contacts"=>total_contacts,
      "zero_amount_donations"=>zero_amount_donations, "non_zero_amount_donations"=>non_zero_amount_donations
    }.to_json
  end

  it { expect(described_class).to be < NfgCsvImporter::Onboarder::OnboarderPresenter }

  before { h.stubs(:import).returns(mock('import')) }

  shared_examples_for 'calling the right presenter' do |method_to_call|
    it 'should be defined' do
      expect(preview_confirmation_presenter).to respond_to(method_to_call)
    end

    it 'should call user presenter' do
      NfgCsvImporter::Onboarder::Steps::UserPresenter.any_instance.expects(method_to_call)
      subject
    end

    context 'for a donation' do
      let(:humanize) { 'donation' }

      it 'should call donation presenter' do
        NfgCsvImporter::Onboarder::Steps::DonationPresenter.any_instance.expects(method_to_call)
        subject
      end
    end

    context 'for a user_supplement' do
      let(:humanize) { 'user_supplement' }

      it 'should call donation presenter' do
        NfgCsvImporter::Onboarder::Steps::UserSupplementPresenter.any_instance.expects(method_to_call)
        subject
      end
    end
  end

  describe "#humanized_card_header_icon" do

    let(:humanize) { 'user' }

    subject { preview_confirmation_presenter.humanized_card_header_icon(humanize) }

    it_behaves_like 'calling the right presenter', :humanized_card_header_icon
  end

  describe '#humanized_card_heading' do
    let(:humanize) { 'user' }

    before do
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:rows_to_render).returns(rows_to_render)
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:nfg_csv_importer_to_host_mapping).returns(nfg_csv_importer_to_host_mapping)
    end

    subject { preview_confirmation_presenter.humanized_card_heading(humanize) }

    it_behaves_like 'calling the right presenter', :humanized_card_heading
  end

  describe '#humanized_card_heading_caption' do
    let(:humanize) { 'user' }

    before do
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:rows_to_render).returns(rows_to_render)
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:nfg_csv_importer_to_host_mapping).returns(nfg_csv_importer_to_host_mapping)
    end

    subject { preview_confirmation_presenter.humanized_card_heading_caption(humanize) }

    it_behaves_like 'calling the right presenter', :humanized_card_heading_caption
  end

  describe '#humanized_card_body' do

    let(:humanize) { 'user' }

    before do
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:rows_to_render).returns(rows_to_render)
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:nfg_csv_importer_to_host_mapping).returns(nfg_csv_importer_to_host_mapping)
    end

    subject { preview_confirmation_presenter.humanized_card_body(humanize) }

    it_behaves_like 'calling the right presenter', :humanized_card_body
  end

  describe '#humanized_card_body_symbol' do
    let(:keyword) { 'address' }
    let(:present) { true }

    subject { preview_confirmation_presenter.humanized_card_body_symbol(keyword, present) }

    it { is_expected.to eq 'home' }

    context 'when present is false' do
      let(:present) { false }

      it { is_expected.to eq "" }
    end

    context 'when keyword is unknown' do
      let(:keyword) { 'some-keyword' }

      it { is_expected.to eq 'circle inverse' }
    end
  end

  describe '#humanized_card_body_icon' do
    let(:keyword) { 'address' }
    let(:humanize) { 'user' }

    before do
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:rows_to_render).returns(rows_to_render)
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:nfg_csv_importer_to_host_mapping).returns(nfg_csv_importer_to_host_mapping)
    end

    subject { preview_confirmation_presenter.humanized_card_body_icon(humanize, keyword) }

    it { is_expected.to eq 'home' }

    context 'when keyword is unknown' do
      let(:keyword) { 'some-keyword' }

      it { is_expected.to eq 'circle inverse' }
    end
  end

  describe "#macro_summary_heading_value" do
    let(:humanize) { 'user' }

    before do
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:rows_to_render).returns(rows_to_render)
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:nfg_csv_importer_to_host_mapping).returns(nfg_csv_importer_to_host_mapping)
    end

    subject { preview_confirmation_presenter.macro_summary_heading_value(humanize) }

    it_behaves_like 'calling the right presenter', :macro_summary_heading_value
  end

  describe "#macro_summary_charts" do
    let(:humanize) { 'user' }

    before do
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:rows_to_render).returns(rows_to_render)
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:nfg_csv_importer_to_host_mapping).returns(nfg_csv_importer_to_host_mapping)
    end

    subject { preview_confirmation_presenter.macro_summary_charts(humanize) }

    it_behaves_like 'calling the right presenter', :macro_summary_charts
  end

  describe "#macro_summary_heading_icon" do

    let(:humanize) { 'user' }

    before do
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:rows_to_render).returns(rows_to_render)
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:nfg_csv_importer_to_host_mapping).returns(nfg_csv_importer_to_host_mapping)
    end

    subject { preview_confirmation_presenter.macro_summary_heading_icon(humanize) }

    it_behaves_like 'calling the right presenter', :macro_summary_heading_icon
  end

  describe "#macro_summary_heading" do

    let(:humanize) { 'user' }

    before do
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:rows_to_render).returns(rows_to_render)
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:nfg_csv_importer_to_host_mapping).returns(nfg_csv_importer_to_host_mapping)
    end

    subject { preview_confirmation_presenter.macro_summary_heading(humanize) }

    it_behaves_like 'calling the right presenter', :macro_summary_heading
  end
end
