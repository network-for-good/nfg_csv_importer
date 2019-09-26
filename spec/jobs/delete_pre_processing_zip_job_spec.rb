require 'rails_helper'

describe NfgCsvImporter::DeleteZipJob do
  let!(:delete_zip_job) { NfgCsvImporter::DeleteZipJob.new }
  let!(:folder) { 'tmp/some_folder' }
  let(:minutes) { 0 }
  subject { delete_zip_job.perform(folder, minutes) }

  before { FileUtils.mkdir_p(folder) unless Dir.exists?(folder) }

  it 'deletes the folder' do
    expect{ subject }.to change{ Dir.exists?(folder) }.from(true).to(false)
  end

  context 'when file was created more recent than the guard minutes' do
    let(:minutes) { 10 }

    it 'does not delete the folder' do
      expect{ subject }.to_not change{ Dir.exists?(folder) }
    end
  end

end
