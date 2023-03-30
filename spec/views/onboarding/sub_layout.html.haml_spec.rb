require 'rails_helper'

RSpec.describe 'onboarding/sub_layout.html.haml' do
  before do
    # no need render the full sub layout (and all of its dependencies)
    # since that should be tested elsewhere. We just need it to
    # yield the block that is passed into it
    stub_template "nfg_csv_importer/layouts/onboarding/import_data/_title_bar" => "<p></p>"
    stub_template "nfg_csv_importer/layouts/onboarding/import_data/_navigation_bar" => "<p></p>"
    view.stubs(:details).returns(details)
    view.stubs(:flash).returns(flash_messages)
    view.stubs(:locale_namespace).returns([:some_space])
    view.stubs(:step).returns([:some_step])
    view.stubs(:form).returns(form)
    view.stubs(:wizard_path).returns('some/path')
    view.stubs(:header_message).returns(mock('header_message'))
    form.stubs(:errors).returns(errors)
    form.stubs(:model_name).returns(model_name)
    form.stubs(:to_key).returns([])
    model_name.stubs(:param_key).returns(form)
    errors.stubs(:any?).returns(false)
  end

  let(:details) { %w[val, another_val] }
  let(:flash_messages) { {error: 'some-error'} }
  let(:form) { mock('form', end_with?: false) }
  let(:model_name) { mock('model_name') }
  let(:errors) { mock('errors', full_messages: []) }
  subject { render template: 'nfg_csv_importer/onboarding/_sub_layout' }

  context 'when there are flash messages' do
    it 'should show flash messages' do
      subject
      rendered.should have_content(flash_messages[:error])
    end
  end
end
