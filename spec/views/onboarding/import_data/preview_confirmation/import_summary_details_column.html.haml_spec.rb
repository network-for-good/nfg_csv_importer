require 'rails_helper'

RSpec.describe 'onboarding/import_data/preview_confirmation/import_summary_details_column' do
  let(:onboarder_presenter) do
    mock('onboarder presenter', macro_summary_heading_icon: icon,
         macro_summary_heading: heading, macro_summary_heading_value: caption,
         macro_summary_charts: charts, color_theme: 'green', chart_thickness: 'a')
  end

  let(:humanize) { 'user' }
  let(:icon) { 'user' }
  let(:heading) { 'some heading' }
  let(:caption) { 'some value' }
  let(:body) { [{ body: %w[some body]}] }
  let(:body_icon) { 'an_icon' }
  let(:charts) { [{ title: 'some title', total: 100, percentage: 50}] }

  subject do
    render partial: 'nfg_csv_importer/onboarding/import_data/preview_confirmation/import_summary_details_column',
           locals: {
             onboarder_presenter: onboarder_presenter, humanize: humanize,
             i18n_scope: [:nfg_csv_importer, :onboarding, :import_data, 'preview_confirmation']
           }
  end

  before do
    onboarder_presenter.expects(:color_theme).twice
  end

  it { is_expected.to have_content heading }

  it { is_expected.to have_content caption }

  it { is_expected.to have_content charts.first[:title] }

  it { is_expected.to have_content charts.first[:total] }

end
