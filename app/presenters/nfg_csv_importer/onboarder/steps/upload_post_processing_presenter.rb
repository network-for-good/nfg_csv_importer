module NfgCsvImporter
  module Onboarder
    module Steps
      class UploadPostProcessingPresenter < NfgCsvImporter::Onboarder::OnboarderPresenter

        def show_import_template_menu?
          h.previous_imports.any?
        end
      end
    end
  end
end