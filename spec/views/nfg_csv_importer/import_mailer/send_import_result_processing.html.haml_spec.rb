require 'rails_helper'

RSpec.describe "nfg_csv_importer/import_mailer/send_import_result_processing.html.haml", type: :view do
  let(:imports_listing_row_column_structure_class) { "col-md-2 m-b-half-down-sm" }
  let(:h) { NfgCsvImporter::ImportsController.new.view_context }
  let!(:import) { FactoryBot.create(:import) }
  let(:import_presenter) { NfgCsvImporter::Mailers::ImportMailerPresenter.new(import, h) }
  let(:recipient) { FactoryBot.create(:user) }
  before do
    stub_template "nfg_csv_importer/import_mailer/send_import_result/_milestone.html.haml" => "<p></p>"
    assign(:recipient, recipient)
    assign(:import, import)
    assign(:import_mailer_presenter, import_presenter)
    assign(:locales_scope,[:mailers, :nfg_csv_importer, :send_import_result_mailer])
  end

  subject { render template: 'nfg_csv_importer/import_mailer/send_import_result_processing' }

  it 'renders step template' do
    expect(subject).to render_template 'nfg_csv_importer/import_mailer/send_import_result/_steps'
  end

  it 'renders the right content pertaining to processing status' do
    expect(subject).to have_content I18n.t('mailers.nfg_csv_importer.send_import_result_mailer.body.introduction.processing')
  end
end
