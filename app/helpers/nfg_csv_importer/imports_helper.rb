module NfgCsvImporter
  module ImportsHelper

    def index_alphabetize
      Hash.new { |hash, key| hash[key] = hash[key - 1].next }.merge({ 0 => 'A' })
    end

    def import_status_icon_and_text(import)
      import_status_class = "m-r-quarter"
      case import.status.try(:to_sym)
      when :uploaded
        import_status_icon = "cloud-upload"
        import_status_class += " text-blue"
      when :defined
        import_status_icon = "table"
        import_status_class += " text-blue"
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

      if error_records_count > 0
        if import.status.try(:to_sym) == :processing
          error_file_link_url = "javascript:;"
          import_with_errors_color_class = "text-muted"
          error_file_link_style = "pointer-events: none;"
          error_file_link_tabindex = "-1"

        else
          error_file_link_url = import.error_file.url
          import_with_errors_color_class = "text-danger"
          error_file_link_style = ""
          error_file_link_tabindex = nil
        end

        html =
          "<h5 class='text-danger line-height-1 m-b-quarter'>#{ error_records_count }</h4>
           <p>
             #{ fa_icon 'paperclip', class: import_with_errors_color_class }
             #{ link_to "Error File", error_file_link_url, class: import_with_errors_color_class, style: error_file_link_style, tabindex: error_file_link_tabindex }
           </p>"
      else
        html = fa_icon "minus", class: "text-muted"
      end

      html.html_safe
    end

    def number_of_records_without_errors_based_on_import_status(import)
      if import.status.try(:to_sym) == :uploaded
        html = fa_icon "minus", class: "text-muted"
      else
        html = "<h4>#{ import.number_of_records }</h4>"
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
  end
end
