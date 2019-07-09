require 'rails_helper'

RSpec.describe 'onboarding/import_data/preview_confirmation.html.haml' do
  before do
    # no need render the full sub layout (and all of its dependencies)
    # since that should be tested elsewhere. We just need it to
    # yield the block that is passed into it
    stub_template "nfg_csv_importer/onboarding/_sub_layout.html.haml" => "= yield"
    stub_template "nfg_csv_importer/onboarding/import_data/preview_confirmation/_humanized_data_preview_card" => "<p></p>"
    stub_template "nfg_csv_importer/onboarding/import_data/preview_confirmation/_import_summary_details_column" => "<p></p>"

    view.stubs(:step).returns('preview_confirmation')
    view.stubs(:templates_to_render).returns(templates)
    view.stubs(:macro_templates_to_render).returns(macro_templates)
    view.stubs(:file_origination_type).returns(file_origination_type)
    view.stubs(:onboarder_presenter).returns(onboarder_presenter)
    view.stubs(:import).returns(stub(status: status, imported_records: stub(count: 4), number_of_records: 4, number_of_records_with_errors: 0))
    # view.stubs(:step).returns(:finish)
  end
  let(:templates) { %w(user donation) }
  let(:macro_templates) { %w(user) }
  let(:status) { "complete" }
  let(:file_origination_type) { mock('file_origination_type', name: 'paypal')}
  let(:onboarder_presenter) { mock('onboarder presenter') }

  subject { render template: 'nfg_csv_importer/onboarding/import_data/preview_confirmation' }

  context 'when the file_origination_type_name and import status have a matching partial' do

    it 'should render the partial for the templates_to_render' do
      expect(subject).to render_template(partial: 'nfg_csv_importer/onboarding/import_data/preview_confirmation/_humanized_data_preview_card', count: 2)
    end

    it 'should render the partial for the templates_to_render' do
      expect(subject).to render_template(partial: 'nfg_csv_importer/onboarding/import_data/preview_confirmation/_import_summary_details_column', count: 1)
    end
  end
end
