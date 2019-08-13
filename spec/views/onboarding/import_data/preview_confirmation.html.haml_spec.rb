require 'rails_helper'

RSpec.describe 'onboarding/import_data/preview_confirmation.html.haml' do
  before do
    # no need render the full sub layout (and all of its dependencies)
    # since that should be tested elsewhere. We just need it to
    # yield the block that is passed into it
    stub_template "nfg_csv_importer/onboarding/_sub_layout.html.haml" => "= yield"
    stub_template "nfg_csv_importer/onboarding/import_data/preview_confirmation/_default_summary_data" => "<p></p>"

    view.stubs(:import_type).returns(import_type)
    view.stubs(:onboarder_presenter).returns(onboarder_presenter)
    view.stubs(:file_origination_type).returns(file_origination_type)
    view.stubs(:step).returns('preview_confirmation')
  end
  let(:display_mappings) { false }
  let(:import_type) { 'preview_confirmation' }
  let(:onboarder_presenter) { mock() }

  let(:file_origination_type) { mock('file_origination_type', name: 'paypal', display_mappings: display_mappings)}

  subject { render template: 'nfg_csv_importer/onboarding/import_data/preview_confirmation' }

  context 'when the import type has a matching partial' do
    before do
      stub_template "nfg_csv_importer/onboarding/import_data/preview_confirmation/_#{import_type}_detail_and_summary_data" => "<p></p>"
    end

    it 'should render the partial for the templates_to_render' do
      expect(subject).to render_template(partial: "nfg_csv_importer/onboarding/import_data/preview_confirmation/_#{import_type}_detail_and_summary_data", count: 1)
    end
  end

  context 'when the import type does not have a matching partial' do
    it 'should render the partial for the templates_to_render' do
      expect(subject).to render_template(partial: "nfg_csv_importer/onboarding/import_data/preview_confirmation/_default_summary_data", count: 1)
    end
  end

  describe 'displaying mappings of the column headers' do

    context 'and when the file origination type does display mappings' do
      let(:display_mappings) { true }
      let(:import) { FactoryGirl.build(:import) }
      before { view.stubs(:import).returns(import) }
      it { is_expected.to render_template('nfg_csv_importer/imports/_mapped_column_headers') }
    end

    context 'and when the file origination type does not display mappings' do
      let(:display_mappings) { false }
      it { is_expected.not_to render_template('nfg_csv_importer/imports/_mapped_column_headers') }
    end
  end
end
