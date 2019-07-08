module NfgCsvImporter
  module Onboarder
    module Steps
      class OverviewPresenter < NfgCsvImporter::Onboarder::OnboarderPresenter
        # Powers Overview content and allows
        # the partials and view to utilize the onboarder_presenter method convention
        include NfgCsvImporter::ImportsHelper
      end
    end
  end
end