require 'rails_helper'

class TestFileOriginationTypeNoNote < NfgCsvImporter::FileOriginationTypes::Base
  # a fake file origination type class so we can test out the use of
  # the collect_note_with_pre_processing_files
  def self.collect_note_with_pre_processing_files
    false
  end
end

class TestFileOriginationTypeNote < NfgCsvImporter::FileOriginationTypes::Base
  def self.collect_note_with_pre_processing_files
    true
  end
end

def fake_form
  # the sublayout needs to supply a form that is passed
  # to its children. The text block below returns
  # a fake version of the the sublayout which requires
  # a lot more setup than is healthy for a simple view
  # spec. So we return this fake form below which
  # mimics what the real sub_layout does, but without
  # all of the overhead
  %Q{
- import = NfgCsvImporter::Import.new
- form = NfgCsvImporter::Onboarding::ImportData::UploadPreprocessingForm.new(import)
= form_for(form, url: '/path') do |f|
  = yield f
  }
end

RSpec.describe 'onboarding/import_data/upload_preprocessing.html.haml', type: :view do
  before do
    stub_template "nfg_csv_importer/onboarding/_sub_layout.html.haml" => fake_form

    view.stubs(:rails_direct_uploads_url).returns('some/path')
    view.stubs(:delete_attachment_path).returns('some/path')
    view.stubs(:file_origination_type).returns(file_origination_type)
    view.stubs(:step).returns('upload_preprocessing')
  end

  subject { render template: 'nfg_csv_importer/onboarding/import_data/upload_preprocessing' }

  let(:form) { stub("form") }

  context 'when the file origination type does not want a note collected when uploading the preprocessing files' do
    let(:file_origination_type) { NfgCsvImporter::FileOriginationTypes::FileOriginationType.new(:test_file_origination_type_no_note, TestFileOriginationTypeNoNote) }

    it 'should not display the note field' do
      expect(subject).not_to have_content(I18n.t('labels.note', scope: [:nfg_csv_importer, :onboarding, :import_data, :upload_preprocessing]))
      expect(subject).not_to have_field('nfg_csv_importer_onboarding_import_data_upload_preprocessing_note')
    end
  end

  context 'when the file origination type wants a note collected when uploading the preprocessing files' do
    let(:file_origination_type) { NfgCsvImporter::FileOriginationTypes::FileOriginationType.new(:test_file_origination_type_note, TestFileOriginationTypeNote) }

    it 'should display the note field' do
      expect(subject).to have_content(I18n.t('labels.note', scope: [:nfg_csv_importer, :onboarding, :import_data, :upload_preprocessing]))
      expect(subject).to have_field('nfg_csv_importer_onboarding_import_data_upload_preprocessing_note')
    end
  end
end
