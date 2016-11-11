#= require jquery
#= require jquery_ujs
# mousetrap
# keybindings
# turbolinks
# handlebars-v4.0.5
# jquery.ui.datepicker
# jquery.ui.sortable
# readmore.min
# tree ../../../vendor/assets/javascripts/redactor
# Chart.min
# twitter/typeahead
# select2.min
# blockUI.min
# moment
# bootstrap-datetimepicker
#= require tether.min
# accountingjs
# jquery.sticky
# directory ../../../vendor/assets/javascripts/linkify
# Bootstrap4
#= require bootstrap4/bootstrap.min
# NFG_CSV_IMPORTER Coffee
#= require_self
# require nfg_csv_importer/ignore_importer_column
# require nfg_csv_importer/auto_save_notification
# require nfg_csv_importer/selecting_column_header
# require nfg_csv_importer/highlight_interacted_column
# require nfg_csv_importer/import_spinner
#= require nfg_csv_importer/set_events_on_import_column
#= require nfg_csv_importer/header_bar
#= require nfg_csv_importer/fields_mapper
#= require nfg_csv_importer/scroll_importer_columns
#= require nfg_csv_importer/modal

window.NfgCsvImporter = {}

$(document).on 'turbolinks:load', ->
  $("a.text-glow").click ->
    fields_mapper = new NfgCsvImporter.FieldsMapper
    fields_mapper.toggleHighlights()

  fields_mapper = new NfgCsvImporter.FieldsMapper
  fields_mapper.setEventListeners
