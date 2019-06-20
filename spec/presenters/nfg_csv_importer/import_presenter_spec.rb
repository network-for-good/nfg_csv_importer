require "rails_helper"
include Rails.application.routes.url_helpers

# Note: this spec was written before Import pre_processing is actually implemented
# It will need to be re-visisted and signed off on.
# JR - May 31, 2019
describe NfgCsvImporter::ImportPresenter do
  let(:h) { NfgCsvImporter::ImportsController.new.view_context }
  let(:import) { FactoryGirl.create(:import) }
  let(:import_presenter) { described_class.new(import, h) }
  let(:file_origination_type) { NfgCsvImporter::Import::PRE_PROCESSING_TYPE_OTHER_NAME }

  # Bypass the params check for file_origination_type that the presenter relies on
  before { import_presenter.h.stubs(:params).returns({ file_origination_type: file_origination_type }) }

  describe '#file_origination_types' do
    subject { import_presenter.file_origination_types }

    it { is_expected.to eq NfgCsvImporter::Import::PRE_PROCESING_TYPES }
  end

  describe '#get_started_information_step(step:, heading_options: {}, body_options: {})' do
    let(:step) { 1 }
    let(:file_origination_type) { import_presenter.file_origination_types.sample.first }
    let(:heading_options) { { file_origination_type: file_origination_type } }

    subject { import_presenter.get_started_information_step(step: step, heading_options: heading_options, body_options: {}) }

    it 'outputs the correct I18n entry with the options present' do
      expect(subject).to include h.ui.nfg(:typeface,
              heading: I18n.t("nfg_csv_importer.pre_processes.get_started_modal.file_origination_type.step1.heading", file_origination_type: file_origination_type))

      expect(subject).to include h.ui.nfg(:typeface,
             body: I18n.t("nfg_csv_importer.pre_processes.get_started_modal.file_origination_type.step1.body"))
    end
  end

  describe '#get_started_information_step_image(step:)' do
    let(:tested_step) { 1 }
    let(:step) { tested_step }
    subject { import_presenter.get_started_information_step_image(step: step) }

    it { is_expected.to eq h.image_tag "nfg_csv_importer/illustrations/get-started-step#{tested_step}.png" }
  end

  describe '#show_pick_import_type_button?' do
    subject { import_presenter.show_pick_import_type_button? }

    context 'when the import file_origination_type is not a third-party' do
      let(:file_origination_type) { NfgCsvImporter::Import::PRE_PROCESSING_TYPE_OTHER_NAME }
      it { is_expected.to be }
    end

    context 'when the import file_origination_type is a third-party' do
      let(:file_origination_type) { NfgCsvImporter::Import::PRE_PROCESSING_TYPE_CONSTANT_CONTACT_NAME }
      it { is_expected.not_to be }
    end
  end

  describe '#file_origination_type_is_other?' do
    subject { import_presenter.file_origination_type_is_other? }

    context 'when the import file_origination_type is not a third-party' do
      let(:file_origination_type) { NfgCsvImporter::Import::PRE_PROCESSING_TYPE_OTHER_NAME }
      it { is_expected.to be }
    end

    context 'when the import file_origination_type is a third-party' do
      let(:file_origination_type) { NfgCsvImporter::Import::PRE_PROCESSING_TYPE_CONSTANT_CONTACT_NAME }
      it { is_expected.not_to be }
    end
  end

  describe '#show_time_estimate?' do
    subject { import_presenter.show_time_estimate? }

    context 'when the import file_origination_type is not a third-party' do
      let(:file_origination_type) { NfgCsvImporter::Import::PRE_PROCESSING_TYPE_OTHER_NAME }
      it { is_expected.not_to be }
    end

    context 'when the import file_origination_type is a third-party' do
      let(:file_origination_type) { NfgCsvImporter::Import::PRE_PROCESSING_TYPE_CONSTANT_CONTACT_NAME }
      it { is_expected.to be }
    end
  end

  describe '#external_resource_url' do
    subject { import_presenter.external_resource_url }
    it { is_expected.to eq I18n.t("nfg_csv_importer.urls.knowledge_base.walk_throughs.file_origination_types.#{file_origination_type}") }
  end

  describe '#import_type_value_for_pre_process_form' do
    pending 'this method should not live in the import presenter'
    subject { import_presenter.import_type_value_for_pre_process_form }

    context 'when the file_origination_type is constant contact' do
      let(:file_origination_type) { NfgCsvImporter::Import::PRE_PROCESSING_TYPE_CONSTANT_CONTACT_NAME }
      it { is_expected.to eq 'users' }
    end

    context 'when the file_origination_type is mailchimp' do
      let(:file_origination_type) { NfgCsvImporter::Import::PRE_PROCESSING_TYPE_MAILCHIMP_NAME }
      it { is_expected.to eq 'users' }
    end

    context 'when the file_origination_type is paypal' do
      let(:file_origination_type) { NfgCsvImporter::Import::PRE_PROCESSING_TYPE_PAYPAL_NAME }
      it { is_expected.to eq 'donations' }
    end

    context 'when not a third-party type' do
      let(:file_origination_type) { NfgCsvImporter::Import::PRE_PROCESSING_TYPE_OTHER_NAME }

      it 'is expected to have the default value from factorygirl' do
        expect(subject).to eq 'users'
      end
    end
  end
end