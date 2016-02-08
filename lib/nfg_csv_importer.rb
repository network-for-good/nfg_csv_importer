require "nfg_csv_importer/engine"
require "roo"
require "carrierwave"
require "haml"
require "simple_form"
require "will_paginate"

module NfgCsvImporter
  class Configuration
    attr_accessor :entity_class, :user_class, :base_controller_class, :user_method, :from_address, :reply_to_address
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
