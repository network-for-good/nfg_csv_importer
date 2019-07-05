module NfgCsvImporter
  # This needs to inherit from GemPresenter when Imports are real.
  #
  # I anticipate we'll write an ImportResultsPresenter
  # and the preview will inherit or overwrite the output methods for the actual output page. They are the same layout with different info coming in.
  module Onboarder
    module Steps
      class UserSupplementPresenter < NfgCsvImporter::Onboarder::Steps::PreviewConfirmationPresenter
        attr_accessor :preview_records
        # TODO: 2ND USER TEMPLATE
      end
    end
  end
end
