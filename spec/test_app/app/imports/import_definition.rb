class ImportDefinition < NfgCsvImporter::ImportDefinition
  IMPORT_TYPES = [:user]
  attr_accessor :imported_for
  def user
    {
      required_columns: %w{ email },
      optional_columns: %w{first_name last_name full_name},
      default_values: { "first_name" => lambda { |row| row["email"][/[^@]+/] } },
      field_aliases: { "first_name" => ["first", "donor first name"],
                      "last_name" => ["last", "donor last name"],
                      "salutation" => ["prefix"]
                      },
      column_validation_rules: [
                                  { type: "any",
                                    fields: ["first_name", "full_name"],
                                    message: "You must map a column to either <strong>First Name</strong> or <strong>Full Name</strong>"
                                  }
                                ],
      class_name: "User",
      alias_attributes: [],
      column_descriptions: {},
      description: %Q{Allows you to import subscribers that then can receive daily, weekly, or newsletter emails. All of the columns listed above must be included in your file. Only the Email column is required to have a value. If first_name is blank, the system will set it to the text prior to the @ in the email.}
    }
  end

  def donation
    {
      required_columns: %w{ amount donated_at },
      optional_columns: %w{description},
      default_values: { "first_name" => lambda { |row| row["email"][/[^@]+/] } },
      class_name: "User",
      alias_attributes: [],
      column_descriptions: {},
      description: %Q{Allows you to import subscribers that then can receive daily, weekly, or newsletter emails. All of the columns listed above must be included in your file. Only the Email column is required to have a value. If first_name is blank, the system will set it to the text prior to the @ in the email.}
    }
  end
end