require "rails_helper"

describe NfgCsvImporter::Onboarder::Steps::PreviewConfirmationPresenter do
  let(:h) { NfgCsvImporter::Onboarding::ImportDataController.new.view_context }
  let(:onboarding_session) { FactoryGirl.create(:onboarding_session, *traits) }
  let(:traits) { [:"#{current_step}_step"] } # auto-generate the correct onboarding session step
  let(:current_step) { 'preview_confirmation' }
  let(:onboarder_presenter) { NfgCsvImporter::Onboarder::OnboarderPresenter.build(onboarding_session, h) }

  before { h.controller.stubs(:params).returns(id: current_step) }

  it { expect(described_class).to be < NfgCsvImporter::Onboarder::OnboarderPresenter }

  describe '#preview_pie_chart(amount:, total:, theme: :primary)' do
    let(:tested_theme) { :primary }
    let(:base_number) { 1 }
    let(:tested_amount) { base_number }
    let(:tested_total) { (tested_amount.to_f * 2) }

    subject { onboarder_presenter.preview_pie_chart(amount: tested_amount, total: tested_total, theme: tested_theme) }


    it 'renders the themed chartwell pie chart with 50 filled in' do
      expect(subject).to eq "<div class=\"chartwell pies mr-2\" style=\"font-size: 76px; line-height: 1;\"><span class=\"text-#{tested_theme.to_s}\">50</span><span class=\"text-light\">50</span><span class=\"text-white\">C</span></div>"
    end
  end

  describe '#preview_card_data(data:, heading: false)' do
    let(:tested_data) { nil }
    let(:tested_heading) { nil }
    subject { onboarder_presenter.preview_card_data(data: tested_data, heading: tested_heading) }

    context 'when data is present' do
      let(:tested_data) { 'Jack Smith' }
      context 'when heading is true' do
        let(:tested_heading) { true }
        it 'renders a heading typeface component' do
          expect(subject).to eq h.ui.nfg(:typeface, heading: tested_data, class: 'mb-0')
        end
      end

      context 'when heading is false' do
        let(:tested_heading) { false }
        it 'renders a body typeface component' do
          expect(subject).to eq h.ui.nfg(:typeface, body: tested_data, class: 'mb-0')
        end
      end
    end

    context 'when data is not present' do
      let(:tested_data) { nil }
      context 'when heading is true' do
        let(:tested_heading) { true }
        it 'renders a not available heading typeface component with a tooltip' do
          expect(subject).to eq h.ui.nfg(:typeface, :muted, heading: h.ui.nfg(:icon, 'info-circle', :primary, :right, text: 'Not available'), tooltip: I18n.t('nfg_csv_importer.onboarding.import_data.preview_confirmation.tooltips.preview_card_data_not_present'))
        end
      end

      context 'when heading is false' do
        let(:tested_heading) { false }
        it 'renders a not available body typeface component with a tooltip' do
          expect(subject).to eq h.ui.nfg(:typeface, :muted, body: h.ui.nfg(:icon, 'info-circle', :primary, :right, text: 'Not available'), tooltip: I18n.t('nfg_csv_importer.onboarding.import_data.preview_confirmation.tooltips.preview_card_data_not_present'))
        end
      end
    end
  end

  describe 'private methods' do
    describe '#calculate_percentage(amount:, total:)' do
      let(:tested_amount) { 1 }
      let(:tested_total) { 2 }
      let(:expected_answer) { 50 } # 50%
      subject { onboarder_presenter.send(:calculate_percentage, amount: tested_amount, total: tested_total) }

      it 'returns the amount divided by total times 100 ceiled which is a whole number of 50 (which is 50%)' do
        expect(subject).to eq expected_answer
      end
    end

    describe '#calculate_remainder(amount:, total:)' do
      let(:tested_amount) { 1 }
      let(:tested_total) { 2 }
      let(:expected_answer) { 50 } # 50%
      subject { onboarder_presenter.send(:calculate_remainder, amount: tested_amount, total: tested_total) }
      it 'the remainder out of 100 of the whole number representation of the associated percentage (50, which is 50%)' do
        expect(subject).to eq expected_answer
      end
    end
  end
end
