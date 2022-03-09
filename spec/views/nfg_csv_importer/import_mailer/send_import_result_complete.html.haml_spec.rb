require 'rails_helper'

RSpec.describe "nfg_csv_importer/import_mailer/send_import_result_complete.html.haml", type: :view do
  let(:imports_listing_row_column_structure_class) { "col-md-2 m-b-half-down-sm" }
  let(:h) { NfgCsvImporter::ImportsController.new.view_context }
  let!(:import) { FactoryGirl.create(:import, number_of_records_with_errors: '5') }
  let(:import_presenter) { NfgCsvImporter::Mailers::ImportMailerPresenter.new(import, h) }
  let(:recipient) { FactoryGirl.create(:user) }

  before do
    stub_template "nfg_csv_importer/import_mailer/send_import_result/_milestone.html.haml" => "<p></p>"
    assign(:recipient, recipient)
    assign(:import, import)
    assign(:import_mailer_presenter, import_presenter)
    view.stubs(:import_url).returns('some-url')
    assign(:locales_scope,[:mailers, :nfg_csv_importer, :send_import_result_mailer])
  end

  subject { render template: 'nfg_csv_importer/import_mailer/send_import_result_complete.html.haml' }

  it 'renders the right content pertaining to complete status' do
    expect(subject).to have_content I18n.t('mailers.nfg_csv_importer.send_import_result_mailer.body.introduction.complete')
  end

  context 'when import mailer presenter has errors' do
    before { NfgCsvImporter::Mailers::ImportMailerPresenter.any_instance.stubs(:errors?).returns(true) }

    it 'renders step template' do
      expect(subject).to render_template partial: 'nfg_csv_importer/import_mailer/send_import_result/_steps'
    end

    it 'shows the number of errors' do
      expect(subject).to have_content "5 records had errors."
    end
  end
end
