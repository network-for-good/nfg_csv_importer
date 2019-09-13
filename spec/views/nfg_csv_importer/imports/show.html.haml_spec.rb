require 'rails_helper'

RSpec.describe 'nfg_csv_importer/imports/show.html.haml' do
  let(:user) { FactoryGirl.create(:user) }
  let(:tested_import) { FactoryGirl.create(:import, *import_traits, import_type: 'paypal', status: status) }
  let(:import_traits) { [] }
  let!(:import) { assign(:import, tested_import) }
  let(:status) { 'pending' }

  subject { render }

  before do
    view.stubs(:current_user).returns(user)
    import.stubs(:can_be_deleted?).returns(false)
  end

  describe "access to the the import's import_file" do
    context 'when pre_processing files are present' do
      let(:import_traits) { :with_pre_processing_files }
      it 'shows the system generated version of the file' do
        expect(subject).to have_css "[data-describe='system-generated-import-file']"

        and_it 'does not show the user-generated import file' do
          expect(subject).not_to have_css "[data-describe='user-generated-import-file']"
        end
      end
    end

    context 'when the status is complete' do
      let(:status) { 'complete' }

      it 'does not error and loads the page' do
        expect(subject).to have_content I18n.t('nfg_csv_importer.imports.show.imported_by')
      end
    end

    context 'when pre_processing files are not present' do
      it 'shows the user generated version of the file' do
        expect(subject).to have_css "[data-describe='user-generated-import-file']"

        and_it 'does not show the system-generated import file' do
          expect(subject).not_to have_css "[data-describe='system-generated-import-file']"
        end
      end
    end
  end
end
