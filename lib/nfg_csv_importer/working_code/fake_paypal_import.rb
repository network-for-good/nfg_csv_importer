module NfgCsvImporter
  module WorkingCode

    # Used for adding in some settings for the import definitions, in play on the test_app:
    # spec/test_app/app/imports/import_definition.rb
    module FakePaypalImport
      def self.fake_paypal_import
        OpenStruct.new(
          id: 0,
          import_type: 'donation',
          import_file: nil,
          error_file: nil,
          imported_for_id: nil,
          imported_by_id: nil,
          status: nil,
          records_processed: nil,
          created_at: Time.now - 1.minute,
          updated_at: nil,
          fields_mapping: nil,
          import_file_name: nil,
          processing_started_at: nil,
          file_origination_type: paypal_file_origination_type,
          number_of_records: 10000,
          # Added in for preview confirmation step
          # approximating the data we'll be showing
          # in some manner from scanned info from the post-processed importable file.
          preview: preview,
          summary: summary,

          # Bring over the definitions from the host app for now.
          **host_app_import_definitions
        )
      end

      def self.preview
        OpenStruct.new(
          user: fake_user,
          donation: fake_donation
        )
      end

      def self.summary
        OpenStruct.new(
          donations: fake_donations,
          donation_total: fake_donations.collect { |a| a.amount }.sum,
          users: fake_users,
          addresses: fake_users.collect { |a| a.address.presence }.reject(&:nil?),
          emails: fake_users.collect { |a| a.email.presence }.reject(&:nil?)
        )
      end

      def self.fake_donation
        OpenStruct.new(
          amount: 100,
          user: fake_user,
          campaign: fake_campaign,
          donated_at: Date.yesterday,
          transaction_id: '7F5W9MF3L4SB',
          note: "On behalf of Jones Day and in lieu of attending 75th Anniversary Gala 2019"
        )
      end

      def self.fake_donations
        donations = []
        20.times { donations << fake_donation }
        donations
      end

      def self.fake_user
        OpenStruct.new(
          name: 'Erika Johnson',
          home_phone: '443-324-0094',
          email: (1 == rand(2) ? 'e.johnson@gmail.com' : nil),
          address: '1017 Rodgers Rd.',
          address_2: 'Apt. 3',
          city: 'Churchton',
          state: 'MD',
          zip_code: '20733',
          country: 'USA'
        )
      end

      def self.fake_users
        fake_donations.collect { |a| a.user }
      end

      def self.fake_campaign
        OpenStruct.new(name: 'Save the Whales')
      end

      private

      def self.host_app_import_definitions
        ::ImportDefinition.get_definition('donation', nil, nil).to_h
      end

      def self.paypal_file_origination_type
        NfgCsvImporter::FileOriginationTypes::Manager.new(NfgCsvImporter.configuration).types.select { |t| t.type_sym == :paypal }.first
      end
    end
  end
end