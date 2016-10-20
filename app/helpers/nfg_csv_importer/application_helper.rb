module NfgCsvImporter
  module ApplicationHelper
    def index_alphabetize
      Hash.new { |hash, key| hash[key] = hash[key - 1].next }.merge({ 0 => 'A' })
    end
  end
end
