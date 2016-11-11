module NfgCsvImporter
  module ImportsHelper

    def index_alphabetize
      Hash.new { |hash, key| hash[key] = hash[key - 1].next }.merge({ 0 => 'A' })
    end

    def import_status_icon_and_text(import)
      case import.status.to_sym
      when :uploaded
        import_status_icon = "cloud-upload"
        import_status_class = "text-primary"
      when :defined
        import_status_icon = "table"
        import_status_class = "text-primary"
      when :queued
        import_status_icon = "hourglass-2"
        import_status_class = "text-warning"
      when :processing
        import_status_icon = "refresh"
        import_status_class = "text-warning"
      when :complete
        import_status_icon = "check"
        import_status_class = "text-success"
      when :deleting
        import_status_icon = "trash-o"
        import_status_class = "text-danger"
      when :deleted
        import_status_icon = "trash-o"
        import_status_class = "text-danger"
      end

      link_to(import_path(import), class: import_status_class) do
        "#{fa_icon(import_status_icon, class: ['m-r-quarter', import_status_class].join(' '))} #{import.status.titleize}".html_safe
      end
    end

    def number_of_records_with_errors_based_on_import_status(import)
      if import.status.to_sym == :uploaded
        fa_icon("minus", class: "text-muted").html_safe
      elsif import.error_file.file.present?
        html = "<span style='text-danger'>#{import.number_of_records_with_errors.to_i}</span>".html_safe
        html += "<small>#{fa_icon 'paperclip', class: 'text-danger'} #{link_to "Error File", import.error_file.url, class: 'text-danger'}</small>".html_safe
      else
        html = import.number_of_records_with_errors.to_i
      end
      html
    end

    def number_of_records_without_errors_based_on_import_status(import)
      if import.status.to_sym == :uploaded
        fa_icon("minus", class: "text-muted").html_safe
      else
        import.number_of_records
      end
    end
  end
end
