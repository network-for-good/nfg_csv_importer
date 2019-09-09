require 'rails_helper'

describe NfgCsvImporter::DeleteZipJob do
  let!(:delete_zip_job) { NfgCsvImporter::DeleteZipJob.new }
  let!(:folder) { 'tmp/some_folder' }

  subject { delete_zip_job.perform(folder) }

  before { FileUtils.mkdir_p(folder) unless Dir.exists?(folder) }

  it 'deletes the folder' do
    expect{ subject }.to change{ Dir.exists?(folder) }.from(true).to(false)
  end

end
