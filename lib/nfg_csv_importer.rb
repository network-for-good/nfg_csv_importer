require "nfg_csv_importer/engine"
require "roo"
require "carrierwave"
require "haml"
require "simple_form"

module NfgCsvImporter
  module ApplicationHelper
    def method_missing(method, *args, &block)
      if (method.to_s.end_with?('_path') || method.to_s.end_with?('_url')) && main_app.respond_to?(method)
        main_app.send(method, *args)
      else
        super
      end
    end
  end

  class Configuration
    attr_accessor :entity_class, :user_class, :base_controller_class, :from_address, :reply_to_address

    def entity_field
      (entity_class.downcase + "_id")
    end

    def user_field
      (user_class.downcase + "_id")
    end
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
