require 'rails_helper'

RSpec.describe 'nfg_csv_importer/imports/show.html.haml' do
  let(:user) { FactoryGirl.create(:user) }
  let(:tested_import) { FactoryGirl.create(:import, *import_traits, import_type: 'paypal', status: status) }
  let(:import_traits) { [] }
  let!(:import) { assign(:import, tested_import) }
  let(:status) { 'complete' }
  subject { render }

  before do
    view.stubs(:current_user).returns(user)
    view.stubs(:imports_path).returns('some/path')
    import.stubs(:can_be_deleted?).returns(false)
  end

  describe "render" do

    it 'does not error and loads the page' do
      expect(subject).to have_content I18n.t('imports.show.imported_by')
    end
  end
end
