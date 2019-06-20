module NfgCsvImporter
  module Onboarder
    module Steps
      # Ex: NfgCsvImporter::Onboarder::NavigationBarPresenter.new(onboarding_session)
      class GetStartedPresenter < NfgCsvImporter::Onboarder::OnboarderPresenter

        def get_started_information_step(step:)
          h.ui.nfg(:typeface,
                    heading: I18n.t("nfg_csv_importer.onboarding.import_data.get_started.body.step#{step}.heading", file_origination_type: file_origination_type_name)) +
          h.ui.nfg(:typeface,
                   body: I18n.t("nfg_csv_importer.onboarding.import_data.get_started.body.step#{step}.body"))
        end

        def get_started_information_step_image(step:)
          h.image_tag "nfg_csv_importer/illustrations/get-started-step#{step}.png"
        end

        def show_time_estimate?
          file_origination_type.type_sym != NfgCsvImporter::FileOriginationTypes::Manager::DEFAULT_FILE_ORIGINATION_TYPE_SYM
        end

        def external_resource_url
          I18n.t("nfg_csv_importer.urls.knowledge_base.walk_throughs.file_origination_types.#{file_origination_type_name}")
        end
      end
    end
  end
end