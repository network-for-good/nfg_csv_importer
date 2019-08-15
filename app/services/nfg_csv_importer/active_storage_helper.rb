# frozen_string_literal: true

module NfgCsvImporter
  class ActiveStorageHelper
    class << self
      def find_by_signed_id(signed_id)
        ActiveStorage::Blob.find_signed(signed_id)
      end

      def get_file_extension(record)
        record&.filename&.extension
      end
    end
  end
end
