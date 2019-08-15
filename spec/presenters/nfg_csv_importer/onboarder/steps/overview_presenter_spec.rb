require "rails_helper"

describe NfgCsvImporter::Onboarder::Steps::OverviewPresenter do
  it { expect(described_class).to be < NfgCsvImporter::Onboarder::OnboarderPresenter }
  it { expect(described_class.included_modules).to include NfgCsvImporter::ImportsHelper }
end
