require "rails_helper"

describe NfgCsvImporter::Onboarder::Steps::NavigationBarPresenter do
  let(:h) { NfgCsvImporter::Onboarding::ImportDataController.new.view_context }
  let(:navigation_bar_presenter) { described_class.new(onboarding_session, h) }
  let(:onboarding_session) { NfgOnboarder::Session.new(name: 'import_data', current_step: current_step) }
  let(:first_step) { :first }
  let(:last_step) { :last }
  let(:steps) { [first_step, :second, last_step] }
  let(:current_step) { first_step }

  before do
    h.controller.stubs(:params).returns(id: current_step)
    h.controller.stubs(:wizard_steps).returns(steps)
  end

  describe '#show_nav?' do
    subject { navigation_bar_presenter.show_nav? }

    context "when current step is the first" do
      let(:current_step) { :first }

      it 'will be false' do
        expect(subject).to be_falsey
      end
    end

    context "when current step is not the first" do
      let(:current_step) { :second }

      it 'will be true' do
        expect(subject).to be_truthy
      end
    end
  end

  describe '#next_button_traits(step:, import:)' do
    let(:tested_step) { :first }
    let(:tested_import) { create(:import) }
    let(:ready_to_import) { nil }

    subject { navigation_bar_presenter.next_button_traits(step: tested_step, import: tested_import) }

    before { tested_import.stubs(:ready_to_import?).returns(ready_to_import) }

    context 'when step is not :field_mapping' do
      it 'does not supply the :disabled trait' do
        expect(subject).to eq [:submit]
        expect(subject).not_to include :disabled
      end
    end

    context 'when step is :field_mapping' do
      let(:tested_step) { :field_mapping }
      context 'and when import is ready to import' do
        let(:ready_to_import) { true }
        it 'does not supplye the :disabled trait' do
          expect(subject).to eq [:submit]
          expect(subject).not_to include :disabled
        end
      end

      context 'and when import is not ready to import' do
        let(:ready_to_import) { false }
        it 'does not supply the :disabled trait' do
          expect(subject).to eq [:submit, :disabled]
        end
      end
    end
  end

  describe "#href(step, path: '')" do
    let(:tested_step) { :first }
    let(:tested_path) { nil }
    let(:before_point_of_no_return) { nil }
    subject { navigation_bar_presenter.href(tested_step, path: tested_path) }

    before { h.stubs(:before_last_visited_point_of_no_return?).with(tested_step).returns(before_point_of_no_return) }

    context 'when #before_last_visited_point_of_no_return? is true' do
      let(:before_point_of_no_return) { true }
      it 'returns nil so that the step is not clickable' do
        expect(subject).to be_nil
      end
    end

    context 'when #before_last_visited_point_of_no_return? is false' do
      let(:before_point_of_no_return) { false }
      let(:tested_path) { '/tested/path' }
      it 'returns the path so that the step is clickable' do
        expect(subject).to eq tested_path
      end
    end
  end
end