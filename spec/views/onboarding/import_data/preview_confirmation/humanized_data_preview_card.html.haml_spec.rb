require 'rails_helper'

RSpec.describe 'onboarding/import_data/preview_confirmation/humanized_data_preview_card' do
  let(:onboarder_presenter) do
    mock('onboarder presenter', color_theme: 'green', humanized_card_header_icon: icon,
         humanized_card_heading: heading, humanized_card_heading_caption: caption,
         humanized_card_body: body, humanized_card_body_icon: body_icon)
  end

  let(:humanize) { 'user' }
  let(:icon) { 'user' }
  let(:heading) { 'some heading' }
  let(:caption) { %w(captain_1 caption_2) }
  let(:body) { [{ body: %w(some body)}] }
  let(:body_icon) { 'an_icon' }

  subject do
    render partial: 'nfg_csv_importer/onboarding/import_data/preview_confirmation/humanized_data_preview_card',
           locals: { onboarder_presenter: onboarder_presenter, humanize: humanize }
  end

  it { is_expected.to have_content heading }

  it { is_expected.to have_content caption.last }

  it { is_expected.to have_content caption.first }

  it { is_expected.to have_content body.first[:body].first }

  it { is_expected.to have_content body.first[:body].last }
end
