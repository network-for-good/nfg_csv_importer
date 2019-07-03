# frozen_string_literal: true

module NfgCsvImporter
  class PreviewTemplateService

    attr_accessor :import, :template
    delegate :preview_template, :rows_with_required_columns, to: :import

    def initialize(import:)
      @import = import
    end

    def templates_to_render
      preview_template&.with_indifferent_access&.dig('templates_to_render') || []
    end

    def columns_to_render
      preview_template&.with_indifferent_access&.dig('columns_to_show') || []
    end

    def rows_to_render
      rows_with_required_columns(required_rows: 1, required_preview_columns: columns_to_render) || []
    end

    def nfg_csv_importer_to_host_mapping
      preview_template&.with_indifferent_access&.dig('nfg_csv_importer_to_host_mapping') || {}
    end
  end
end
