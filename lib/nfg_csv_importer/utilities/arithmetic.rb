module NfgCsvImporter
  module Utilities
    class Arithmetic
      class << self
        def percentage(subset, total)
          if total.to_i == 0
            0
          else
            sprintf "%.2f", ((subset.to_f / total.to_f) * 100.0)
          end
        end
      end
    end
  end
end
