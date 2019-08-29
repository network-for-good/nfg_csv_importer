module NfgCsvImporter
  module Onboarder
    # Ex: NfgCsvImporter::Onboarder::TitleBarPresenter.new(onboarding_session)
    class TitleBarPresenter < NfgCsvImporter::Onboarder::OnboarderPresenter
      def title_bar_caption
        I18n.t('nfg_csv_importer.onboarding.import_data.title_bar.caption')
      end
    end
  end
end