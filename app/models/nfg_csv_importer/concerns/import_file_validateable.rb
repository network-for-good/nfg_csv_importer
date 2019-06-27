# frozen_string_literal: true

module NfgCsvImporter
  module Concerns
    module ImportFileValidateable
      # This includes all of the methods that are used
      # to validate the import_file
      extend ActiveSupport::Concern

      def empty_column_headers
        # header is actually a list of headers. I know, it is confusing
        # returns a list of indexes that have blank headers
        header.each_with_index.select { |hdr, i| hdr.strip.blank? }.map(&:last)
      end

      def duplicated_headers
        NfgCsvImporter::DupeHeaderFinder.new(header).call
      end

      def import_validation
        begin
          if import_file.blank?
            errors.add :base, "Import File can't be blank, Please Upload a File"
            return false
          end
          validate_empty_columns
          validate_duplicate_headers
        rescue => e
          errors.add :base, "We weren't able to parse your spreadsheet.  Please ensure the first sheet contains your headers and import data and retry.  Contact us if you continue to have problems and we'll help troubleshoot."
          Rails.logger.error e.message
          Rails.logger.error e.backtrace.join("\n")
          return false
        end
        true
      end

      def import_file_extension_validation
        # valid_file_extension is delegated to the service provided by
        # the ImportServiceable concern.
        # Don't attempt to validate the extension if there is no file
        return if attached_file.nil?
        return if valid_file_extension?
        # ipso facto, the file extension must be invalid
        errors.add :base, 'The file must be an xls, xlsx, or csv'
      end

      private

      def validate_empty_columns
        return if empty_column_headers.empty?
        # empty_column_headers contains an array of column indexes starting at 0. We need to increment
        # to match a users expectation that they start at 1
        columns_that_have_empty_headers = empty_column_headers.map { |c| c + 1 }.join(", ")
        errors.add :base, "The following columns have an empty header: #{ columns_that_have_empty_headers }"
      end

      def validate_duplicate_headers
        return if duplicated_headers.empty?
        duplicate_column_list_str = duplicated_headers.inject("") { |str, hdr, dupes| str += "#{ dupes.map(&:first).joins(", ") } are duplicate headers found in columns #{ dupes.map(&:last).map { |c| c + 1 }.joins(", ") }"}
        #{duplicated_headers.map { |dupe, columns| "'#{dupe}' on columns #{columns.join(' & ')}" }.join('; ')
        errors.add :base, "The column headers contain duplicate values. Either modify the headers or delete a duplicate column. #{ duplicate_column_list_str }"
      end
    end
  end
end
