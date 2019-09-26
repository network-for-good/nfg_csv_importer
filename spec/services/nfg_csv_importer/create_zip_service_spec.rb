require 'rails_helper'
require 'roo'

RSpec.describe NfgCsvImporter::CreateZipService do
  let(:create_zip_service) { NfgCsvImporter::CreateZipService.new(model: model, attr: attr, user_id: user.id) }
  let(:user) { create(:user) }
  let(:model) { import }
  let(:attr) { 'pre_processing_files' }

  describe '#call' do
    let(:folder) { "tmp/archive_#{user.id}"}
    let(:delete_job) { mock('delete_zip_job', perform_later: nil) }
    subject { create_zip_service.call }

    after { FileUtils.remove_dir(folder) if Dir.exists?(folder) }

    context 'when pre_processing_files exist' do
      before do
        NfgCsvImporter::DeleteZipJob.stubs(:set).returns(delete_job)
        ActiveStorage::Attachment.any_instance.expects(:service_url).returns('some-url')
        Object.any_instance.expects(:open).returns(File.open("spec/fixtures/individual_donation.csv")).twice
      end

      let!(:import) { create(:import, :with_pre_processing_files) }

      it 'creates a zip file' do
        expect{ subject }.to change {
          File.file?("#{folder}/#{import.class.name}_#{import.id}.zip")
        }.from(false).to(true)
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
