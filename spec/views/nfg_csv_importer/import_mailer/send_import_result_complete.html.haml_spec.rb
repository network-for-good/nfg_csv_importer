require 'rails_helper'

RSpec.describe "nfg_csv_importer/import_mailer/send_import_result_complete.html.haml", type: :view do
  let(:imports_listing_row_column_structure_class) { "col-md-2 m-b-half-down-sm" }
  let(:h) { NfgCsvImporter::ImportsController.new.view_context }
  let!(:import) { FactoryGirl.create(:import, *import_traits, imported_by: imported_by) }
  let(:import_traits) { [:is_complete, :is_paypal, :with_pre_processing_files] }
  let(:import_presenter) { NfgCsvImporter::Mailers::ImportMailerPresenter.new(import, h) }
  let(:current_user) { FactoryGirl.create(:user) }
  let(:imported_by) { current_user }
  let(:tested_can_be_viewed_by) { true }
  let(:recipient) { FactoryGirl.create(:user) }
  before do
    view.stubs(:current_user).returns(current_user)
    import.stubs(:can_be_viewed_by).with(current_user).returns(tested_can_be_viewed_by)
    stub_template "nfg_csv_importer/import_mailer/send_import_result/_milestone.html.haml" => "<p></p>"
    assign(:recipient, recipient)
    assign(:import, import)
    view.stubs(:import_url).returns('some-url')
  end

  subject { render template: 'nfg_csv_importer/import_mailer/send_import_result_complete.html.haml' }

  it 'renders step template' do
    expect(subject).to have_content I18n.t('mailers.nfg_csv_importer.send_import_result_mailer.body.introduction.complete')
  end
end
