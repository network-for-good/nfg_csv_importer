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
    attr_accessor :imported_for_class, :imported_by_class, :base_controller_class,
                  :from_address, :reply_to_address, :imported_for_subdomain

    def imported_for_field
      (imported_for_class.downcase + "_id")
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
