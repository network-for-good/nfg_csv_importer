require "nfg_csv_importer/engine"
require "roo"
require "carrierwave"
require "haml"
require "simple_form"

module NfgCsvImporter
  class Configuration
    attr_accessor :entity_class, :user_class, :base_controller_class, :user_method
  end

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end
  end
end
