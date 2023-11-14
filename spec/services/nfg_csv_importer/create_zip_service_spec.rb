require 'rails_helper'
require 'roo'

RSpec.describe NfgCsvImporter::CreateZipService do
  let(:create_zip_service) { NfgCsvImporter::CreateZipService.new(model: model, attr: attr, user_id: user.id) }
  let(:user) { create(:user) }
  let(:model) { import }
  let(:attr) { 'pre_processing_files' }
  let(:filename) { 'paypal_sample_file_1.xlsx' }

  describe '#call' do
    let(:folder) { "tmp/archive_#{user.id}"}
    subject { create_zip_service.call }

    after { FileUtils.remove_dir(folder) if Dir.exists?(folder) }

    context 'when pre_processing_files exist' do
      before do
        NfgCsvImporter::DeleteZipJob.stubs(:perform_in)
        ActiveStorage::Attachment.any_instance.expects(:download).returns(fake_string_from_file)
        Object.any_instance.expects(:open).returns(File.open("spec/fixtures/individual_donation.csv")).times(3)
      end

      let!(:import) { create(:import, :with_pre_processing_files) }
      let(:zip_file) { "#{folder}/#{import.class.name}_#{import.id}.zip" }
      let(:fake_string_from_file) { File.open("spec/fixtures/individual_donation.csv").read }

      it 'creates a zip file' do
        expect{ subject }.to change {
          File.file?(zip_file)
        }.from(false).to(true)

        # open zip file and check if it contains the right file name
        names = Zip::File.open(zip_file) { |zip| zip.entries.map(&:name) }
        expect(names).to eq([filename])
      end
    end

    context 'when pre_processing_files do not exist' do
      let(:import) { create(:import) }

      it 'returns nil' do
        expect(subject).to eq(nil)
      end
    end
  end
end
