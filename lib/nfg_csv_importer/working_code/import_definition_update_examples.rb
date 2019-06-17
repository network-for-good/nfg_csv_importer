module NfgCsvImporter
  module WorkingCode

    # Used for adding in some settings for the import definitions, in play on the test_app:
    # spec/test_app/app/imports/import_definition.rb
    module ImportDefinitionUpdateExamples
      def self.donation_humanized_data_set
        { humanized_data_set: {
          'user' => {
            'heading' => %w[name],
            'summary' => %w[home_phone email],
            'full_address' => %w[address
                                 address2
                                 city
                                 state
                                 zip_code
                                 country]
            },

            'donation' => {
              'heading' => %w[amount],
              'summary' => %w[campaign.name donated_at],
              'id' => %w[transaction_id],
              'note' => %w[note]
            }
          }
        }
      end


      # "Let’s meet %{user_name}. They made a %{donation_amount} donation to your %{donation_campaign_name} on %{donation_date}."
      def self.donation_preview_sentence_summary_data_set
        { preview_sentence_summary_data_set: {
            'user' => %w[name],
            'donation' => %w[amount campaign.name donated_at]
          }
        }
      end

      def self.donation_summary_data_set
        { summary_data_set: {
            'user' => {
              # Assuming you'd pick a specific set of methods to collect these.

              # Summary
              'total' => {
                'Total Est. Contacts' => 'number_of_records'
              },
              'charts' => {
                # dms column header names
                'With Emails' => 'emails.size',
                'With Addresses' => 'addresses.size'
              }
            },
            'donation' => {
              # Total up all the amount columns...
              'total' => {
                'Total Est. Donations' => 'summary.donation_total'
              },
              # Calculate number of records
              # And where donation amount is 0 (to be changed later)
              'charts' => {
                'Regular Donations' => 'donations.size',
                'In-Kind Donations' => 'donations.size' # where amount is $0
              }
            }
          }
        }
      end

      def self.user_humanized_data_set
        { humanized_data_set: {
          'user' => {
            'heading' => %w[name],
            'summary' => %w[home_phone email],
            'full_address' => %w[address
                                 address2
                                 city
                                 state
                                 zip_code
                                 country]
            }
          }
        }
      end

      def self.user_preview_sentence_summary_data_set
        { preview_sentence_summary_data_set: {
            'user' => %w[name]
          }
        }
      end

      def self.user_summary_data_set
        { summary_data_set: {
            'user' => {
              # Assuming you'd pick a specific set of methods to collect these.

              # Summary
              'total' => {
                'Total Est. Contacts' => 'number_of_records'
              },
              'charts' => {
                # dms column header names
                'With Emails' => 'emails.size',
                'With Addresses' => 'addresses.size'
              }
            }
          }
        }
      end
    end
  end
end