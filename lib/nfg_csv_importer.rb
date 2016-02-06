require "nfg_csv_importer/engine"
require "roo"
require "carrierwave"
require "haml"
require "simple_form"

module NfgCsvImporter
  mattr_accessor :entity_class
  mattr_accessor :user_class
  mattr_accessor :inherited_controller
  mattr_accessor :user_method
end
