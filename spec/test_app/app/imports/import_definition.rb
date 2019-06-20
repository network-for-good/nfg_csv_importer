class ImportDefinition < NfgCsvImporter::ImportDefinition

  include NfgCsvImporter::WorkingCode::ImportDefinitionUpdateExamples

  def self.import_types
    %w{users donation}
  end

  attr_accessor :imported_for
  def users
    {
      required_columns: %w{ email },
      optional_columns: %w{first_name last_name full_name tribue_attribute_and_notification_preference_with_salutation surname wealth_score college_degree last_donation_date note },
      default_values: { "first_name" => lambda { |row| row["email"].try(:split, "@").try(:first) } },
      field_aliases: { "first_name" => ["first", "donor first name"],
                      "last_name" => ["last", "donor last name"],
                      "email" => ["email"]
                      },
      column_validation_rules: [
                                  { type: "any",
                                    fields: ["first_name", "full_name"],
                                    message: "You must map a column to either <strong>First Name</strong> or <strong>Full Name</strong>"
                                  }
                                ],
      fields_that_allow_multiple_mappings: ["note"],
      class_name: "User",
      alias_attributes: [],
      column_descriptions: {
          'first_name' => "The numeric internal ID of the individual record. Only empty fields will be updated. New data will not overwrite existing data. To update donation records, please use the update_donation importer.",
          'last_name' => 'Must be a valid email address',
          'full_name' => "If other address fields are included, and country is left blank, it will be set to 'US'",
          'tribue_attribute_and_notification_preference_with_salutation' => "Mr, Mrs, Ms, Dr, etc",
          'surname' => 'Must be either m or f (m = male, f = female)',
          'wealth_score' => "Use this value to ensure that multiple donation records get attributed to a single donor. All records with the same external_user_id will be attached to one donor record using the information in the first row containing that external_user_id",
          'college_degree' => "Notes are displayed on the contact's profile"
        },
      description: %Q{Allows you to import subscribers.},
      can_be_deleted_by: -> (user) { user.last_name != "Jones" },

      **NfgCsvImporter::WorkingCode::ImportDefinitionUpdateExamples.user_humanized_data_set,

      **NfgCsvImporter::WorkingCode::ImportDefinitionUpdateExamples.user_summary_data_set
    }
  end

  def donation
    {
      required_columns: %w{ amount donated_at },
      optional_columns: %w{description},
      default_values: {},
      class_name: "Donation",
      alias_attributes: [],
      column_descriptions: {},
      can_be_viewed_by: -> (user) { user.last_name != "Smith" },
      description: %Q{Allows you to import donations},

      **NfgCsvImporter::WorkingCode::ImportDefinitionUpdateExamples.donation_humanized_data_set,

      **NfgCsvImporter::WorkingCode::ImportDefinitionUpdateExamples.donation_summary_data_set
    }
  end
end
