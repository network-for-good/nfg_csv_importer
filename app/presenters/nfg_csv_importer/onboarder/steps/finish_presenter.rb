module NfgCsvImporter
  module Onboarder
    module Steps
      class FinishPresenter < NfgCsvImporter::Onboarder::OnboarderPresenter
        def queued_alert_msg
          if queue_index == 0
            "Your import is next in line."
          else
            "There #{queue_index == 1 ? 'is' : 'are'} #{h.pluralize(queue_index, 'import')} in line ahead of yours."
          end
        end

        private

        def queue_index
          @queue_index ||= NfgCsvImporter::Import.queued.pluck(:id).index(h.import.id) || 0
        end
      end
    end
  end
end