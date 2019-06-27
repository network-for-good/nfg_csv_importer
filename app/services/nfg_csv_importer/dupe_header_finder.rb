module NfgCsvImporter
  class DupeHeaderFinder
    attr_accessor :headers

    def initialize(headers)
      @headers = headers
    end

    def call
      duplicates
    end

    # private

    def formatted_headers
      # replaces spaces with underscores and downcases the string.
      #  "First name" becomes "first_name". We are assuming that
      # "first_name", "First Name", "First_Name", "first name" are all the same.
      headers.map { |h| h.downcase.strip.gsub(" ","_") }
    end

    def unique_non_blank_formatted_headers
      # let's eliminate duplicates from this list of formatted headers to
      # make it easier then to generate a list of those formatted headers
      # that have duplicates.
      formatted_headers.uniq.select(&:present?)
    end

    def headers_with_dupe_indexes
      # looks at each unique formatted header and identifies
      # those formatted headers that match it. This means that
      # each unique formatted header will be returned, with most
      # just pointing to themselves (if they have no dupes).
      # For each unique formatted header it will return a list of
      # original headers whose formatted header matches it, along with
      # the index of where this header is in the list of headers.
      # So for the following headers:
      # ["First Name", "email", "first_name", "last_name", "first name", "address"]
      # it produces the following hash
      # {
      #  "first_name"=>[["First Name", 0], ["first_name", 2], ["first name", 4]],
      #  "email"=>[["email", 1]],
      #  "last_name"=>[["last_name", 3]],
      #  "address"=>[["address", 5]]
      # }
      unique_non_blank_formatted_headers.inject({}) do |hsh, hdr|
        hsh[hdr] = headers.each_with_index.select {|h, i| formatted_headers[i] == hdr}
        hsh
      end
    end

    def duplicates
      # returns just the entries in the hash above that have more than one value (i.e. have duplicates)
      headers_with_dupe_indexes.select { |hdr, dupes| dupes.length > 1 }
    end
  end
end