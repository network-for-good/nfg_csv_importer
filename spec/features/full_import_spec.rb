require 'rails_helper'

describe "Running through the full import process", js: true do
  let!(:entity) { Entity.create(subdomain: "test") }
  let(:upload_button_name) { I18n.t("nfg_csv_importer.imports.new.form.buttons.upload") }

  describe "from the new import page" do
    let(:new_import_path) { nfg_csv_importer.new_import_path(import_type: 'users') }

    before(:each) do
      @user = User.create(first_name: "Jim", last_name: "Smith", email: "jim@smith.com", entity: entity)
    end

    it "should be able to import users" do
      visit new_import_path
      # should have download template link
      expect(page).to have_link(I18n.t("links.file", scope: [:nfg_csv_importer, :imports, :new]), href: NfgCsvImporter::Engine.routes.url_helpers.template_imports_path(import_type: 'users'))
      # upload and continue button should be disabled prior to adding file
      expect(page).to have_button(upload_button_name, disabled: true)
      attach_file("import_import_file", File.expand_path("spec/fixtures/users_for_full_import_spec.xls"))
      # button should be enabled after attaching the file
      expect(page).to have_button(upload_button_name)
      expect { submit_import_file_form }.to change(NfgCsvImporter::Import, :count).by(1)

      within("#importer_gem_modal_first_visit") do
        expect(page).to have_content("Great News")
        expect(page).to have_content("4\nColumns to be Imported")
        expect(page).to have_content("3\nAutomatically Mapped Columns")
      end

      expect(page.find('.modal-open')).to be
      find("button.close").click
      sleep 1

      new_import = NfgCsvImporter::Import.last
      expect(current_path).to eq(nfg_csv_importer.edit_import_path(new_import))
      within("#importer_header_stats") do
        expect(page).to have_content("6\nROWS")
        expect(page).to have_content("4\nCOLUMNS")
        expect(page).to have_content("0\nIGNORED COLUMNS")
        expect(page).to have_content("1\nUNMAPPED COLUMNS")
        expect(page).to have_content("Not ready to import")
      end

      # click to ignore the unmapped column
      within("div[data-column-name='other'] .card-header-interactions") do
        page.find("label").click
      end

      # Confirm the css change is complete before checking
      # that the language is present.
      sleep 1
      expect(page.find('#card_header_other .label-danger')).to be

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
        expect(page).to have_content("0\nIGNORED COLUMNS")
        expect(page).to have_content("1\nUNMAPPED COLUMNS")
        expect(page).to have_content("Not ready to import")
      end

      # map the unmapped column to duplicate column
      within("div[data-column-name='other']") do
        select "First Name", from: "import_fields_mapping_b3RoZXI__"
      end
      within("#importer_header_stats") do
        expect(page).to have_content("0\nIGNORED COLUMNS")
        expect(page).to have_content("0\nUNMAPPED COLUMNS")
        expect(page).to have_content("Not ready to import")
      end
      within(".container-error") do
        expect(page).to have_content("multiple columns with the same mapped header")
        expect(page).to have_content("Your Original Header:\nfirst_name")
        expect(page).to have_content("Your Original Header:\nother")
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
        expect(page).to have_content("1\nIGNORED COLUMNS")
        expect(page).to have_content("1\nUNMAPPED COLUMNS")
        expect(page).to have_content("Not ready to import")
      end

      # map the unmapped column to a valid field
      within("div[data-column-name='first_name']") do
        select "First Name", from: "import_fields_mapping_Zmlyc3RfbmFtZQ___"
      end
      within("#importer_header_stats") do
        expect(page).to have_content("1\nIGNORED COLUMNS")
        expect(page).to have_content("0\nUNMAPPED COLUMNS")
        expect(page).to have_content("Ready to import")
      end

      # move to the review page
      click_link "Review & Confirm"

      expect(current_path).to eq(nfg_csv_importer.import_review_path(new_import))

      expect do
        click_link "I'm Ready, Let's Import"
        sleep 1
      end.to change(User, :count).by(3)

      page.driver.browser.navigate.refresh
      expect(current_path).to eq(nfg_csv_importer.import_path(new_import))

      expect(User.find_by(email: "tim@farlow.com")).to be

      expect(page).to have_content("Your import is complete")

      expect(page).to have_content("New records created\n3")
      expect(page).to have_content("Processed rows\n6")
      expect(page).to have_content("Errors within your data\n3")
      expect(page).to have_link("Error file")
    end
  end

  describe "imports index page" do
    let(:file) { File.open('spec/fixtures/users_for_full_import_spec.xls')}
    let(:donation_file) { File.open('spec/fixtures/donations.xlsx')}
    let(:user_1) { FactoryGirl.create(:user, first_name: "Pavan", last_name: "Jones") }
    let!(:import) { FactoryGirl.create(:import, imported_by: user_1, updated_at: 1.minute.ago, import_file: file, imported_for: entity, status: "complete", processing_finished_at: 7.minutes.ago) }
    let!(:import2) { FactoryGirl.create(:import, imported_by: user_1, updated_at: 10.minutes.ago, import_file: file, imported_for: entity, status: "uploaded") }
    let!(:import3) { FactoryGirl.create(:import, imported_by: user_1, updated_at: 8.minutes.ago, import_file: file, imported_for: entity, status: "complete", processing_finished_at: 7.minutes.ago) }
    let!(:donation_import) { FactoryGirl.create(:import, import_type: "donation", imported_by: user_1, updated_at: 8.minutes.ago, import_file: donation_file, imported_for: entity, status: "complete", processing_finished_at: 7.minutes.ago) }

    before do
      visit nfg_csv_importer.imports_path

      # ensure we're on the page before the test runs.
      # This is a flakey path for capybara for some reason.
      expect(page.find("[data-view-wrapper='importer-gem']", wait: 5)).to be
    end

    describe 'showing the correct import slats' do
      let(:imports_created_by_user_1) { NfgCsvImporter::Import.where(imported_by: user_1) }

      context "when the user is allowed to see all of the files" do
        # the import definition for the donation import excludes users with "Smith" as the last name
        it "should display all the imports" do
          and_it 'shows all of the imports to the user' do
            expect(page).to have_css "[data-describe='import-slat']", count: imports_created_by_user_1.size
            expect(page).to have_selector "[data-describe='imported-by-name']", text: user_1.name, count: imports_created_by_user_1.size

            and_it 'shows the import the user is allowed to uniquely see' do
              expect(page).to have_css "[data-import-type='donation']"
            end
          end

          and_it 'accurately links you to the imports show page' do
            within "#import_#{import.id}" do
              click_link 'Details'
            end

            expect(page).to have_css "#import_#{import.id}[data-describe='import-show-page']"
          end
        end
      end

      context "when the user is NOT allowed to see certain files" do
        let(:user_1) { FactoryGirl.create(:user, first_name: "Pavan", last_name: "Smith") }

        # the import definition for the donation import excludes users with "Smith" as the last name
        it "should display all the imports sorted in recent order" do
          expect(page).to have_css "#imports_listing [data-describe='import-slat']", count: 3

          expect(page).not_to have_css("#import_#{ donation_import.id }")

          and_it 'does not show the import type that the user is not allowed to see' do
            expect(page).not_to have_css "[data-import-type='donation']"
          end
        end
      end
    end
  end
end

def submit_import_subscribers_file
  with_resque { submit_import_file_form }
  expect(page).to have_content(I18n.t(:notice, scope: [:nfg_csv_importer, :import, :create]))
  expect(current_path).to eq(nfg_csv_importer.import_path(NfgCsvImporter::Import.last))
end

def submit_import_file_form
  click_button "Upload & Continue"
  sleep 1
end
