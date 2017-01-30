require 'rails_helper'

describe "Running through the full import process", js: true do
  let!(:entity) { Entity.create(subdomain: "test") }
  let(:upload_button_name) { I18n.t("imports.new.form.buttons.upload") }

  describe "from the new import page" do
    let(:new_import_path) { nfg_csv_importer.new_import_path(import_type: 'users') }

    before(:each) do
      @user = User.create(first_name: "Jim", last_name: "Smith", email: "jim@smith.com", entity: entity)
    end

    it "should be able to import users" do
      visit new_import_path
      # upload and continue button should be disabled prior to adding file
      sleep 1
      # click_link(I18n.t("imports.new.links.ready_upload"))
      expect(page).to have_button(upload_button_name, disabled: true)
      attach_file("import_import_file", File.expand_path("spec/fixtures/users_for_full_import_spec.xls"))
      sleep 1
      # button should be enabled after attaching the file
      expect(page).to have_button(upload_button_name)
      expect { submit_import_file_form }.to change(NfgCsvImporter::Import, :count).by(1)

      # expect(page).to have_content("Great News! We just saved you some time by by evaluating your columns and applying automatic matches:")
      # expect(page).to have_content("4 Columns To Be Imported")
      # expect(page).to have_content("3 Automatically Mapped Columns")

      find("button.close").click
      new_import = NfgCsvImporter::Import.last
      expect(current_path).to eq(nfg_csv_importer.edit_import_path(new_import))
      within("#importer_header_stats") do
        expect(page).to have_content("6 ROWS")
        expect(page).to have_content("4 COLUMNS")
        expect(page).to have_content("0 IGNORED COLUMNS")
        expect(page).to have_content("1 UNMAPPED COLUMNS")
        expect(page).to have_content("Not ready to import")
      end

      # click to ignore the unmapped column
      within("div[data-column-name='other'] .card-header-interactions") do
        find("label").click
      end

      within("#importer_header_stats") do
        expect(page).to have_content("1 IGNORED COLUMNS")
        expect(page).to have_content("0 UNMAPPED COLUMNS")
        expect(page).to have_content("Ready to import")
      end
      within("div[data-column-name='other']") do
        expect(page).to have_content("Won't be imported")
      end

      # click to un-ignore (allow mapping of)
      within("div[data-column-name='other'] .card-header-interactions") do
        find("label").click
      end
      within("#importer_header_stats") do
        expect(page).to have_content("0 IGNORED COLUMNS")
        expect(page).to have_content("1 UNMAPPED COLUMNS")
        expect(page).to have_content("Not ready to import")
      end

      # map the unmapped column to duplicate column
      within("div[data-column-name='other']") do
        select "First Name", from: "import_fields_mapping_other"
      end
      within("#importer_header_stats") do
        expect(page).to have_content("0 IGNORED COLUMNS")
        expect(page).to have_content("0 UNMAPPED COLUMNS")
        expect(page).to have_content("Not ready to import")
      end
      within(".container-error") do
        expect(page).to have_content("multiple columns with the same mapped header")
        expect(page).to have_content("Your Original Header: first_name")
        expect(page).to have_content("Your Original Header: other")
      end

      # unmap the other column and allow for editing
      within("div[data-column-name='other']") do
        click_link "Edit Column"
      end

      # click to ignore the unmapped column
      within("div[data-column-name='other'] .card-header-interactions") do
        find("label").click
      end

      # unmap a column and allow for editing
      within("div[data-column-name='first_name']") do
        click_link "Edit Column"
      end
      within("#importer_header_stats") do
        expect(page).to have_content("1 IGNORED COLUMNS")
        expect(page).to have_content("1 UNMAPPED COLUMNS")
        expect(page).to have_content("Not ready to import")
      end

      # map the unmapped column to a valid field
      within("div[data-column-name='first_name']") do
        select "First Name", from: "import_fields_mapping_first_name"
      end
      within("#importer_header_stats") do
        expect(page).to have_content("1 IGNORED COLUMNS")
        expect(page).to have_content("0 UNMAPPED COLUMNS")
        expect(page).to have_content("Ready to import")
      end

      # move to the review page
      click_link "Review & Confirm"

      expect(current_path).to eq(nfg_csv_importer.import_review_path(new_import))

      expect do
        click_link "I'm Ready, Let's Import"
      end.to change(User, :count).by(3)

      expect(current_path).to eq(nfg_csv_importer.import_path(new_import))

      expect(User.find_by(email: "tim@farlow.com")).to be

      expect(page).to have_content("Your users import is complete")

      expect(page).to have_content("New records created 3")
      expect(page).to have_content("Processed rows 6")
      expect(page).to have_content("Errors within your data 3")
      expect(page).to have_link("Error file")
    end
  end

  describe "imports index page" do
    let(:file) { File.open('spec/fixtures/users_for_full_import_spec.xls')}
    let(:donation_file) { File.open('spec/fixtures/donations.xlsx')}

    before do
      FactoryGirl.create(:import, imported_by: user_1, updated_at: 10.minutes.ago, import_file: file, imported_for: entity, status: "uploaded")
      FactoryGirl.create(:import, imported_by: user_1, updated_at: 8.minutes.ago, import_file: file, imported_for: entity, status: "complete", processing_finished_at: 7.minutes.ago)
      @import = FactoryGirl.create(:import, imported_by: user_1, updated_at: 1.minute.ago, import_file: file, imported_for: entity, status: "complete", processing_finished_at: 7.minutes.ago)
      @donation_import = FactoryGirl.create(:import, import_type: "donation", imported_by: user_1, updated_at: 8.minutes.ago, import_file: donation_file, imported_for: entity, status: "complete", processing_finished_at: 7.minutes.ago)
      visit imports_path
      sleep 1
    end

    context "when the user is allowed to see all of the files" do
      # the import definition for the donation import excludes users with "Smith" as the last name
      let(:user_1) { FactoryGirl.create(:user, first_name: "Pavan", last_name: "Jones") }

      it "should display all the imports sorted in recent order" do
        expect(page.all("#imports_listing div div.row div div.row div h5.m-b-quarter").length).to eq(8) # 2 for each import
        within("#import_#{ @import.id }_name h5") do
         expect(page).to have_content(user_1.name)
        end

        within("#import_#{ @donation_import.id }_name h5") do
         expect(page).to have_content(user_1.name)
        end

        expect(page).to have_content("donations.xlsx")

        # clicking status will take the user to the show page
        within("#import_#{ @import.id }") do
          click_link @import.status.titleize
        end
        expect(current_path).to eq(nfg_csv_importer.import_path(@import))
      end
    end

    context "when the user is NOT allowed to see certain files" do
      # the import definition for the donation import excludes users with "Smith" as the last name
      let(:user_1) { FactoryGirl.create(:user, first_name: "Pavan", last_name: "Smith") }

      it "should display all the imports sorted in recent order" do
        expect(page.all("#imports_listing div div.row div div.row div h5.m-b-quarter").length).to eq(6) # 2 for each import
        expect(page).not_to have_css("#import_#{ @donation_import.id }")
        expect(page).not_to have_content("donation.xlsx")
      end
    end
  end
end

def submit_import_subscribers_file
  with_resque { submit_import_file_form }
  expect(page).to have_content(I18n.t(:notice, scope: [:import, :create]))
  expect(current_path).to eq(nfg_csv_importer.import_path(NfgCsvImporter::Import.last))
end

def submit_import_file_form
  click_button "Upload & Continue"
end
