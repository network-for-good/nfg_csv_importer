module NfgCsvImporter
  module ApplicationHelper
    def import_column_display_name(import_type, column, titleize = false)
      display_name = ""
      display_name = t("imports.column_display_names.#{import_type}.#{column}", default: column) if column.present?
      display_name = display_name.downcase.tr("_", " ").titleize if titleize
      display_name
    end
  end
end
