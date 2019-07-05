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

  describe "#href(step, path: '')" do
    let(:tested_step) { :first } # the logic for this test rests mostly on the controller; so we don't need to change the tested_step once we set it.

    let(:tested_path) { nil }
    subject { navigation_bar_presenter.href(tested_step, path: tested_path) }

    context 'when on the last step in the controller' do
      let(:current_step) { last_step }
      it 'sets all hrefs to nil regardless of the step value so that you cannot click back to any step' do
        expect(subject).to be_nil
      end
    end

    context 'when not on the last step in the controller' do
      let(:current_step) { first_step }
      before { navigation_bar_presenter.stubs(:step_status).with(current_step).returns(tested_step_status) }

      context 'and when the step status is disabled' do
        let(:tested_step_status) { :disabled }
        it 'returns a nil href so that the step is not clickable in the navigation'
        it { is_expected.to be_nil }
      end

      context 'and when the step status is not disabled' do
        let(:tested_step_status) { :active }
        let(:tested_path) { '/tested_path' }
        it 'is given the path it requests' do
          expect(subject).to eq tested_path
        end
      end
    end
  end
end