module NfgCsvImporter
  module ImportsHelper

    def index_alphabetize
      Hash.new { |hash, key| hash[key] = hash[key - 1].next }.merge({ 0 => 'A' })
    end

    def import_delete_confirmation(import)
      if import.pending_or_uploaded_or_calculating_statistics?
        t('nfg_csv_importer.imports.confirmations.delete_without_records')
      else
        t('nfg_csv_importer.imports.confirmations.delete', number_of_records: import.imported_records.size)
      end
    end

    def import_status_link(import)
      import_status_class = ""

      case import.status.try(:to_sym)
      when :uploaded
        import_status_icon = "gear"
        import_status_class += " text-primary"
      when :defined
        import_status_icon = "table"
        import_status_class += " text-primary"
      when :queued
        import_status_icon = "hourglass-2"
        import_status_class += " text-warning"
      when :processing
        import_status_icon = "refresh"
        import_status_class += " text-warning"
      when :pending
        import_status_icon = "circle-o-notch"
        import_status_class += " text-muted"
      when :complete
        import_status_icon = "check"
        import_status_class += " text-success"
      when :deleting
        import_status_icon = "trash-o"
        import_status_class += " text-danger"
      when :deleted
        import_status_icon = "trash-o"
        import_status_class += " text-danger"
      end

      content_tag :strong, class: "m-r-quarter mr-1 #{import_status_class}", data: { describe: 'import-status-link' } do
        fa_icon import_status_icon, text: I18n.t("nfg_csv_importer.imports.index.status.#{import.status}", default: import.status).titleize, class: "mr-1 #{import_status_class}"
      end
    end

    def number_of_records_with_errors_based_on_import_status(import)
      error_records_count = import.number_of_records_with_errors.to_i

      if error_records_count > 0
        if import.status.try(:to_sym) == :processing
          error_file_link_url = "javascript:;"
          import_with_errors_color_class = "text-muted"
          error_file_link_style = "pointer-events: none;"
          error_file_link_tabindex = "-1"
          processing_import_tooltip_for_error_file = true

        else
          error_file_link_url = import.error_file.url
          import_with_errors_color_class = "text-danger"
          error_file_link_style = ""
          error_file_link_tabindex = nil
          processing_import_tooltip_for_error_file = false

        end

        render partial: "import_error_information_on_listing_page",
               locals: { error_records_count: error_records_count,
                         error_file_link_url: error_file_link_url,
                         import_with_errors_color_class: import_with_errors_color_class,
                         error_file_link_style: error_file_link_style,
                         error_file_link_tabindex: error_file_link_tabindex,
                         processing_import_tooltip_for_error_file: processing_import_tooltip_for_error_file
                       }
      else
        fa_icon("minus", class: "text-muted").html_safe
      end


    end

    def number_of_records_without_errors_based_on_import_status(import)
      if import.status.try(:to_sym) == :uploaded
        html = fa_icon "minus", class: "text-muted"
      else
        html = "<h5>#{ import.number_of_records }</h5>"
      end
      html.html_safe
    end

    def bootstrap_tooltip(tooltip_content, placement = :right)
      acceptable_placement_directions = [ :right, :top, :bottom, :left ]

      raise StandardError.new("Acceptable placement options are :right, :top, :bottom or :left, only... and you assigned #{placement}") unless acceptable_placement_directions.include?(placement)

      if is_browser_a_touch_device?
        {}
      else
        { title: tooltip_content, data: { placement: placement, toggle: "tooltip" } }
      end
    end

    def is_browser_a_touch_device?
      browser.mobile? || browser.tablet?
    end

    def import_column_display_name(import_type, column, titleize = false)
      display_name = ""
      display_name = I18n.t("imports.column_display_names.#{import_type}.#{column}", default: column) if column.present?
      display_name = display_name.downcase.tr("_", " ").titleize if titleize
      display_name
    end



    def user_import_definitions(imported_for:, user:, definition_class:, imported_by: )
      definition_class.import_types.reduce({}) do |hash, import_type|
        definition = definition_class.get_definition(import_type, imported_for, imported_by)
        definition.can_be_viewed_by(user) ? hash.merge(import_type => definition) : hash
      end
    end
  end
end
