class ImportDefinition < NfgCsvImporter::ImportDefinition

  def self.import_types
    %w{users donation}
  end

  attr_accessor :imported_for
  def users
    {
      required_columns: %w{ email },
      optional_columns: %w{first_name last_name full_name note},
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
      column_descriptions: {},
      description: %Q{Allows you to import subscribers.}
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
      description: %Q{Allows you to import donations}
    }
  end
end