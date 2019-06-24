module NfgCsvImporter
  # This needs to inherit from GemPresenter when Imports are real.
  #
  # I anticipate we'll write an ImportResultsPresenter
  # and the preview will inherit or overwrite the output methods for the actual output page. They are the same layout with different info coming in.
  module Onboarder
    module Steps
      class PreviewConfirmationPresenter < NfgCsvImporter::Onboarder::OnboarderPresenter
        def humanized_card_header_icon(humanize)
          return 'user' if humanize == 'user'
          return 'dollar' if humanize == 'donation'
        end

        def humanized_card_heading(humanize)
          return 'Erika Johnson' if humanize == 'user'
          return '$25.00' if humanize == 'donation'
        end

        def humanized_card_heading_caption(humanize)
          return ['443-324-0094', 'email@example.com'] if humanize == 'user'
          return ['Save the Whales', 'April 18, 2019'] if humanize == 'donation'
        end

        # Anticipating an array of arrays that we loop through.
        # The keyword might then be used to sync up an icon for this data (e.g.: user address = 'house')
        def humanized_card_body(humanize)
          return [{ address: ['2320 Main St.', 'Apt. 302', 'Reno, NV 22322', 'USA'] }] if humanize == 'user'
          return [{ transaction_id: ['K-7F5W9MF3L4SB']},{ note: ["On behalf of Jones Day and in lieu of attending 75th Anniversary Gala 2019"]}] if humanize == 'donation'
        end

        def humanized_card_body_icon(keyword)
          case keyword.to_s
          when 'address' then 'home'
          when 'transaction_id' then 'search'
          when 'note' then 'file-o'
          else
            'circle inverse'
          end
        end

        def chart_thickness
          'C' # corresponds to the appearance of FF Chartwell pie charts.
        end

        def macro_summary_heading_icon(humanize)
          return 'user' if humanize == 'user'
          return 'dollar' if humanize == 'donation'
        end

        def macro_summary_heading(humanize)
          return "Total Est. Contacts" if humanize == 'user'
          return "Total Est. Donations" if humanize == 'donation'
        end

        def macro_summary_heading_value(humanize)
          return '1,750' if humanize == 'user'
          return '$32,503' if humanize == 'donation'
        end

        def macro_summary_charts(humanize)
          return [{ title: "Arbitrary Example", total: 1750, percentage: 70  }, { title: "Another Example", total: 900, percentage: 30 }] if humanize == 'user'
          return [{ title: "An Example", total: 32500, percentage: 90  }, { title: "Very Real Example", total: 1260, percentage: 80 }] if humanize == 'donation'
        end
      end
    end
  end
end