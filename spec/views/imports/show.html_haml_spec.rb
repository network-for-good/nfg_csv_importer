require 'rails_helper'

RSpec.describe "nfg_csv_importer/imports/show.html.haml", type: :view do
  let(:current_user) { FactoryBot.create(:user) }
  let(:pre_processing_files) { [file] }
  let(:file) { mock('file') }
  let(:import_file) { File.open("spec/fixtures/donations.xlsx") }
  let(:import) { FactoryBot.create(:import, import_file: import_file) }

  before do
    view.stubs(:current_user).returns(current_user)
    view.stubs(:dom_id).returns(1)
    view.stubs(:rails_blob_path).returns('some/path')
    assign(:import, import)
    import.stubs(:pre_processing_files).returns(pre_processing_files)
  end

  subject { render }

  context 'when pre_processing_files are not empty' do
    before do
      file.stubs(:filename).returns('some-file')
      file.stubs(:signed_id).returns(1)
    end

    it 'renders the download links to pre processing files' do
      expect(subject).to have_css "[data-describe='download-pre-processing']"
    end
  end

  context 'when pre_processed file is empty' do
    let(:pre_processing_files) { nil }

    it 'does not render the download links to pre processing files' do
      expect(subject).to_not have_css "[data-describe='download-pre-processing']"
    end
  end
end
