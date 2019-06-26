require "nfg_csv_importer/engine"
require "roo"
require "carrierwave"
require "haml"
require "simple_form"
require "coffee-script"
require "sass-rails"
require "font-awesome-rails"
require "browser"
require "nfg_ui"
require "nfg_csv_importer/configuration"
require "premailer/rails"
require "letter_opener"

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

  class << self
    attr_writer :configuration

    def configuration
      @configuration ||= NfgCsvImporter::Configuration.new
    end

    def configure
      yield configuration
    end
  end
end
