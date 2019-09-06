require 'rails_helper'

describe NfgCsvImporter::DestroyImportJob do
  let!(:delete_pre_processing_zip_job) { NfgCsvImporter::DeletePreProcessingZipJob.new }
  let!(:folder) { 'tmp/some_folder' }

  subject { delete_pre_processing_zip_job.perform(folder) }

  before { FileUtils.mkdir_p(folder) unless Dir.exists?(folder) }

  it 'deletes the folder' do
    expect{ subject }.to change{ Dir.exists?(folder) }.from(true).to(false)
  end

end
