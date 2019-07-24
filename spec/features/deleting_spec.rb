require 'rails_helper'

describe "Deleting imports", js: true do
  let(:entity) { create(:entity) }
  let(:admin) {  create(:user) }
  let(:status) { :complete }
  let(:import) { create(:import, {
    imported_for: entity, imported_by: admin, status: status,
    processing_finished_at: 5.minutes.ago
  })}
  let(:importable) { create(:user, entity: entity) }
  let!(:imported_record) { create(:imported_record, {
    import: import, importable: importable, imported_for: entity,
    imported_by: admin
  })}

  context 'when the import can be deleted by the current user' do
    it 'displays a Delete Import link near the bottom of the page' do
      visit nfg_csv_importer.import_path(import)
      click_link I18n.t("buttons.delete", scope: [:nfg_csv_importer, :imports, :show])

      expect do
        page.driver.browser.switch_to.alert.accept
        sleep 1
      end.to change(User, :count).by(-1)

      expect(import.reload.status).to eq 'deleted'
      expect(page.current_path).to eq nfg_csv_importer.imports_path
    end
  end

  context 'when the can_be_deleted_by proc return false' do
    # The proc is currently setup to return true except for when the current user's
    # last name is "Jones"
    let(:admin) { create(:user, last_name: 'Jones') }
    it "doesn't display the Delete Import link" do
      visit nfg_csv_importer.import_path(import)
      expect(page).not_to have_link 'Delete'
    end
  end
end
