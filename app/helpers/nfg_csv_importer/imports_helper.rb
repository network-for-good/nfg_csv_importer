module NfgCsvImporter
  module ImportsHelper

    def index_alphabetize
      Hash.new { |hash, key| hash[key] = hash[key - 1].next }.merge({ 0 => 'A' })
    end

    def import_status_icon_and_text(import)
      import_status_class = "m-r-quarter"
      case import.status.to_sym
      when :uploaded
        import_status_icon = "cloud-upload"
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

      link_to import_path(import), class: import_status_class do
        "#{ fa_icon import_status_icon, class: import_status_class } #{ import.status.titleize }".html_safe
      end
    end

    def number_of_records_with_errors_based_on_import_status(import)
      error_records_count = import.number_of_records_with_errors.to_i
      import_with_errors_color_class = "m-r-quarter"

      if error_records_count > 0
        if import.status.to_sym == :processing
          error_file_link_url = "javascript:;"
          import_with_errors_color_class += " text-muted"
          error_file_link_style = "pointer-events: none;"
          error_file_link_tabindex = "-1"
        else
          error_file_link_url = import.error_file.url
          import_with_errors_color_class += " text-danger"
          error_file_link_style = ""
          error_file_link_tabindex = nil
        end

        html = "<h4 class='text-danger'>#{ error_records_count }</h4>"
        html += "<small>"
        html += "#{ fa_icon 'paperclip', class: import_with_errors_color_class }"
        html += "#{ link_to "Error File", error_file_link_url, class: import_with_errors_color_class, style: error_file_link_style, tabindex: error_file_link_tabindex }"
        html += "</small>"
      else
        html = fa_icon "minus", class: "text-muted"
      end
      html.html_safe
    end

    def number_of_records_without_errors_based_on_import_status(import)
      if import.status.to_sym == :uploaded
        html = fa_icon "minus", class: "text-muted"
      else
        html = "<h4>#{ import.number_of_records }</h4>"
      end
      html.html_safe
    end

    def edit_import_link(import)
      edit_import_link_class = "btn btn-link"

      if import.status.to_sym == :uploaded
        edit_import_link_url = edit_import_path(import)
        edit_import_link_icon_class = ""
        edit_import_link_tab_index = nil
      else
        edit_import_link_url = "javascript:;"
        edit_import_link_class += " disabled"
        edit_import_link_icon_class = "text-muted"
        edit_import_link_tab_index = "-1"
      end

      link_to edit_import_link_url, class: edit_import_link_class, tabindex: edit_import_link_tab_index do
        "#{ fa_icon 'pencil', class: edit_import_link_icon_class } Edit Import".html_safe
      end
    end
  end
end
