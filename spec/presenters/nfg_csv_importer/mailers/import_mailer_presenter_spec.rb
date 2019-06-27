require "rails_helper"
# include Rails.application.routes.url_helpers
require 'nfg_csv_importer/file_origination_types/self_import_csv_xls'

describe NfgCsvImporter::Mailers::ImportMailerPresenter do
  let(:h) { ActionMailer::Base.new.view_context }
  let(:import_mailer_presenter) { described_class.new(import, h) }
  let(:import) { FactoryGirl.create(:import, *import_traits) }
  let(:import_traits) { [] }
  let(:file_origination_type) { NfgCsvImporter::FileOriginationTypes::FileOriginationType.new(tested_type_sym, FileOriginationTypes::SelfImportCsvXls) }
  let(:tested_type_sym) { :self_import_csv_xls }

  let(:type_sym) { file_origination_type.type_sym }

  it { expect(described_class).to be < NfgCsvImporter::GemPresenter }

  describe '#status_result_alert_message' do
    subject { import_mailer_presenter.status_result_alert_message }
    let(:import_traits) { [:is_paypal, :"is_#{status}"] }
    let(:status) { :complete }

    it 'yields the correct content from I18n result based on Import status' do
      expect(subject).to eq I18n.t("mailers.nfg_csv_importer.send_import_result_mailer.alert.#{status}")
    end
  end
end
