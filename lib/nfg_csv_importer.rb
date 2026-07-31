require_relative "nfg_csv_importer/engine"
# Loads Reform::Rails::Railtie, which wires ActiveModel validations
# (`validates` etc.) into Reform::Form at app boot. Without this require
# the reform-rails gem is installed but never loaded, since gemspec
# dependencies are not auto-required by Bundler.
require "reform/rails"
require "roo"
require "csv"
require "carrierwave"
require "haml"
require "simple_form"
require "coffee-script"
require "sass-rails"
require "font-awesome-rails"
require "nfg_ui"
require "nfg_csv_importer/configuration"
require "premailer/rails"

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
