require "rails_helper"

describe NfgCsvImporter::ImportPresenter do
  let(:view) { ActionController::Base.new.view_context }
  let(:import) { FactoryGirl.create(:import) }
  let(:import_presenter) { described_class.new(import, view) }

  describe '#pre_processing_types' do
    subject { import_presenter.pre_processing_types }

    it { is_expected.to eq NfgCsvImporter::Import::PRE_PROCESING_TYPES }
  end

  describe '#get_started_modal_step(step:, heading_options: {}, body_options: {})' do
    let(:step) { nil }
    let(:heading_options) { {} }

    subject { import_presenter.get_started_modal_step(step: step, heading_options: heading_options, body_options: {}) }

    context 'when heading options are present' do
      let(:step) { 1 }
      let(:pre_processing_type) { import_presenter.pre_processing_types.sample.first }
      let(:heading_options) { { pre_processing_type: pre_processing_type } }

      it 'outputs the correct I18n entry with the options present' do
        expect(subject).to include view.ui.nfg(:typeface,
                heading: I18n.t("nfg_csv_importer.pre_processes.get_started_modal.pre_processing_type.step1.heading", pre_processing_type: pre_processing_type))

        expect(subject).to include view.ui.nfg(:typeface,
               body: I18n.t("nfg_csv_importer.pre_processes.get_started_modal.pre_processing_type.step1.body"))
      end
    end
  end
end