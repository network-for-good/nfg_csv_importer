require 'rails_helper'

RSpec.describe 'onboarding/import_data/finish.html.haml' do
  before do
    # no need render the full sub layout (and all of its dependencies)
    # since that should be tested elsewhere. We just need it to
    # yield the block that is passed into it
    stub_template "nfg_csv_importer/onboarding/_sub_layout.html.haml" => "= yield"

    view.stubs(:file_origination_type_name).returns(file_origination_type_name)
    view.stubs(:import).returns(stub(id: 1, status: status, imported_records: stub(count: 4), number_of_records: 4, number_of_records_with_errors: 0))
    view.stubs(:onboarder_presenter).returns(onboarder_presenter)
    view.stubs(:locale_namespace).returns([:nfg_csv_importer, :onboarding, :import_data])
    view.stubs(:file_origination_type).returns(file_origination_type)
    # view.stubs(:step).returns(:finish)
  end
  let(:file_origination_type) { OpenStruct.new(type_sym: 'paypal') }
  let(:file_origination_type_name) { "paypal" }
  let(:status) { "complete" }
  let(:onboarder_presenter) { OpenStruct.new(queued_alert_msg: 'Your import is next in line.') }

  subject { render template: 'nfg_csv_importer/onboarding/import_data/finish' }

  it 'includes the file origination type symbol as an id used by the Full Story app' do
    expect(subject).to have_css "#paypal"
  end

  context 'when the file_origination_type_name and import status have a matching partial' do

    it 'should render the partial for the file origination type and status' do
      expect(subject).to render_template('nfg_csv_importer/onboarding/import_data/finish/_paypal_complete')
    end
  end

  context "when the file_origination_type_name does not have a matching partial" do
    let(:file_origination_type_name) { "self_import_csv_xls" }

    it 'should render the partial based on the import status' do
      expect(subject).to render_template('nfg_csv_importer/onboarding/import_data/finish/_complete')
    end

    context "when the status also does match a partial" do
      let(:status) { 'pending' }

      it 'should render a default partial' do
        expect(subject).to render_template('nfg_csv_importer/onboarding/import_data/finish/_default')
      end
    end
  end


end
