module NfgCsvImporter
  module Onboarder
    module Steps
      class FinishPresenter < NfgCsvImporter::Onboarder::OnboarderPresenter
        def queued_alert_msg
          if queue_index == 0
            "Your import is in the queue and next in line to be processed!"
          else
            "Your import is in the queue and there #{queue_index == 1 ? 'is' : 'are'} #{h.pluralize(queue_index, 'import')} in line ahead of yours before being processed."
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