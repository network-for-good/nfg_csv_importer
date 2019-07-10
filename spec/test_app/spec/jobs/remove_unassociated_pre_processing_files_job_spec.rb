require 'rails_helper'

RSpec.describe RemoveUnassociatedPreProcessingFilesJob, type: :job do
  subject { RemoveUnassociatedPreProcessingFilesJob.perform_now }
  let!(:blob) { create_blob }

  context 'a day old blob records' do
    before  { blob.update(created_at: 2.days.ago) }

    it 'deletes unassociated blob records' do
      expect { subject }.to change(ActiveStorage::Blob, :count).by(-1)
    end

    context 'when associated with attachment' do
      let(:import) { create(:import, :with_pre_processing_files) }
      let!(:blob) { import.pre_processing_files.first.blob }

      it 'does not deletes it' do
        expect(blob).not_to be_nil
        expect { subject }.to change(ActiveStorage::Blob, :count).by(0)
      end
    end
  end

  it 'does not deletes unassociated blobs created today' do
    expect { subject }.to change(ActiveStorage::Blob, :count).by(0)
  end
end

def create_blob(data: "Hello NFG!", filename: "hello.txt", content_type: "text/plain")
  ActiveStorage::Blob.create_after_upload! io: StringIO.new(data), filename: filename, content_type: content_type
end
