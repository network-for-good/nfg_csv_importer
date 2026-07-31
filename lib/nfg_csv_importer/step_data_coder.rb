module NfgCsvImporter
  # A JSON-backed ActiveRecord `serialize` coder for nfg_onboarder's
  # NfgOnboarder::Session#step_data (and friends). Plain `JSON` loses Symbol
  # keys on every dump/load round trip, but this gem's onboarding code reads
  # nested step_data hashes with Symbol keys throughout. Loading into a
  # HashWithIndifferentAccess (which deep-converts nested hashes/arrays)
  # keeps the JSON storage format while letting Symbol and String key access
  # both work.
  #
  # Configure via: Rails.application.config.default_coder = NfgCsvImporter::StepDataCoder
  module StepDataCoder
    def self.dump(object)
      ActiveSupport::JSON.encode(object)
    end

    def self.load(json)
      return if json.blank?

      decoded = ActiveSupport::JSON.decode(json)
      decoded.respond_to?(:with_indifferent_access) ? decoded.with_indifferent_access : decoded
    end
  end
end
