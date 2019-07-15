require 'rails_helper'

RSpec.describe "nfg_csv_importer/imports/show.html.haml", type: :view do
  let(:current_user) { FactoryGirl.create(:user) }
  let(:pre_processing_files) { [file] }
  let(:file) { mock('file', signed_id: 1) }
  let(:import_file) { File.open("spec/fixtures/donations.xlsx") }
  let(:import) { FactoryGirl.create(:import, import_file: import_file) }

  before do
    view.stubs(:current_user).returns(current_user)
    view.stubs(:dom_id).returns(1)
    assign(:import, import)
    file.stubs(:filename).returns('some-file').twice
    import.stubs(:pre_processing_files).returns(pre_processing_files)
  end

  subject { render }

  it 'renders the download links to pre processing files' do
    expect(subject).to have_css "[data-describe='download-pre-processing']"
  end

  context 'when pre_processed file is empty' do
    let(:pre_processing_files) { nil }

    it 'does not render the download links to pre processing files' do
      expect(subject).to_not have_css "[data-describe='download-pre-processing']"
    end
  end
end
