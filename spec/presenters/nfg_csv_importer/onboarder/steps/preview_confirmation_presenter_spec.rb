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

    # context 'when import statistics do not have the right keys' do
    #   let(:stats) { {}.to_json }
    #   it { is_expected.to eq result }
    # end
  end

  describe "#humanized_card_header_icon" do

    let(:humanize) { 'user' }

    subject { preview_confirmation_presenter.humanized_card_header_icon(humanize) }

    it 'should be defined' do
      expect(preview_confirmation_presenter).to respond_to(:humanized_card_header_icon)
    end

    it 'should call user presenter' do
      NfgCsvImporter::Onboarder::Steps::UserPresenter.any_instance.expects(:humanized_card_header_icon)
      subject
    end

    context 'for a donation' do
      let(:humanize) { 'donation' }

      it 'should call donation presenter' do
        NfgCsvImporter::Onboarder::Steps::DonationPresenter.any_instance.expects(:humanized_card_header_icon)
        subject
      end
    end
  end

  describe '#humanized_card_heading' do
    let(:humanize) { 'user' }

    before do
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:rows_to_render).returns(rows_to_render)
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:nfg_csv_importer_to_host_mapping).returns(nfg_csv_importer_to_host_mapping)
    end

    subject { preview_confirmation_presenter.humanized_card_heading(humanize) }

    it 'should be defined' do
      expect(preview_confirmation_presenter).to respond_to(:humanized_card_heading)
    end

    it 'should call user presenter' do
      NfgCsvImporter::Onboarder::Steps::UserPresenter.any_instance.expects(:humanized_card_heading)
      subject
    end

    context 'for a donation' do
      let(:humanize) { 'donation' }

      it 'should call donation presenter' do
        NfgCsvImporter::Onboarder::Steps::DonationPresenter.any_instance.expects(:humanized_card_heading)
        subject
      end
    end
  end

  describe '#humanized_card_heading_caption' do
    let(:humanize) { 'user' }

    before do
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:rows_to_render).returns(rows_to_render)
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:nfg_csv_importer_to_host_mapping).returns(nfg_csv_importer_to_host_mapping)
    end

    subject { preview_confirmation_presenter.humanized_card_heading_caption(humanize) }

    it 'should be defined' do
      expect(preview_confirmation_presenter).to respond_to(:humanized_card_heading_caption)
    end

    it 'should call user presenter' do
      NfgCsvImporter::Onboarder::Steps::UserPresenter.any_instance.expects(:humanized_card_heading_caption)
      subject
    end

    context 'for a donation' do
      let(:humanize) { 'donation' }

      it 'should call donation presenter' do
        NfgCsvImporter::Onboarder::Steps::DonationPresenter.any_instance.expects(:humanized_card_heading_caption)
        subject
      end
    end
  end

  describe '#humanized_card_body' do

    let(:humanize) { 'user' }

    before do
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:rows_to_render).returns(rows_to_render)
      NfgCsvImporter::PreviewTemplateService.any_instance.stubs(:nfg_csv_importer_to_host_mapping).returns(nfg_csv_importer_to_host_mapping)
    end

    subject { preview_confirmation_presenter.humanized_card_body(humanize) }

    it 'should be defined' do
      expect(preview_confirmation_presenter).to respond_to(:humanized_card_body)
    end

    it 'should call user presenter' do
      NfgCsvImporter::Onboarder::Steps::UserPresenter.any_instance.expects(:humanized_card_body)
      subject
    end

    context 'for a donation' do
      let(:humanize) { 'donation' }

      it 'should call donation presenter' do
        NfgCsvImporter::Onboarder::Steps::DonationPresenter.any_instance.expects(:humanized_card_body)
        subject
      end
    end
  end

  describe "#macro_summary_heading_value" do
    let(:humanize) { 'user' }

    subject { preview_confirmation_presenter.macro_summary_heading_value(humanize) }

    before { h.stubs(:import).returns(mock('import', statistics: stats)) }

    context 'for a user' do
      it { is_expected.to eq total_contacts }

      it_behaves_like 'when import statistics are not available', ""
    end

    context 'for a donation' do
      let(:humanize) { 'donation'}
      it { is_expected.to eq total_amount }

      it_behaves_like 'when import statistics are not available', ""
    end
  end

  describe "#macro_summary_charts" do
    let(:humanize) { 'user' }

    subject { preview_confirmation_presenter.macro_summary_charts(humanize) }

    before { h.stubs(:import).returns(mock('import', statistics: stats)) }

    context 'for a user' do
      let(:response) do
        [{ title: "With Emails", total: num_emails, percentage: "50.00"  },
         { title: "With Addresses", total: num_addresses, percentage: "20.00" }]
      end
      it { is_expected.to eq response }

      it_behaves_like 'when import statistics are not available', [{:percentage=>0, :title=>"With Emails", :total=>""}, {:percentage=>0, :title=>"With Addresses", :total=>""}]
    end

    context 'for a donation' do
      let(:humanize) { 'donation' }
      let(:response) do
        [{ title: "Regular Donations", total: non_zero_amount_donations, percentage: "50.00"  },
         { title: "In-kind Donations", total: zero_amount_donations, percentage: "50.00" }]
      end

      it { is_expected.to eq response }

      it_behaves_like 'when import statistics are not available', [{:percentage=>0, :title=>"Regular Donations", :total=>""}, {:percentage=>0, :title=>"In-kind Donations", :total=>""}]
    end
  end

end
