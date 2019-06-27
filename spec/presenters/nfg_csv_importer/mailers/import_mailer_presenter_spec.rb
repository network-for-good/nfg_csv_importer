require "rails_helper"
# include Rails.application.routes.url_helpers
require 'nfg_csv_importer/file_origination_types/self_import_csv_xls'

describe NfgCsvImporter::Mailers::ImportMailerPresenter do
  let(:h) { ActionMailer::MailersController.new.view_context }
  let(:import_mailer_presenter) { described_class.new(import, h) }

  let(:file_origination_type) { NfgCsvImporter::FileOriginationTypes::FileOriginationType.new(tested_type_sym, FileOriginationTypes::SelfImportCsvXls) }
  let(:tested_type_sym) { :self_import_csv_xls }

  let(:type_sym) { file_origination_type.type_sym }

  it { expect(described_class).to be < NfgCsvImporter::GemPresenter }
end
