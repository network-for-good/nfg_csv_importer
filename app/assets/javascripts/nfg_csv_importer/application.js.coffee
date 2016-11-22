#= require readmore.min
# NFG_CSV_IMPORTER Coffee
#= require_self
#= require nfg_csv_importer/header_bar
#= require nfg_csv_importer/fields_mapper
#= require nfg_csv_importer/modal
#= require nfg_csv_importer/tooltips
#= require nfg_csv_importer/show_and_hide
#= require nfg_csv_importer/smooth_scroll
#= require nfg_csv_importer/bootstrap_custom_file_input
#= require nfg_csv_importer/read_more

window.NfgCsvImporter = {}

if $("head [data-turbolinks-track='true']")
  window.NfgCsvImporter.readyOrTurboLinksLoad = "turbolinks:load"
else
  window.NfgCsvImporter.readyOrTurboLinksLoad = "ready"

$(document).on NfgCsvImporter.readyOrTurboLinksLoad, ->
  $("a.text-glow").click ->
    fields_mapper = new NfgCsvImporter.FieldsMapper
    fields_mapper.toggleHighlights()

  fields_mapper = new NfgCsvImporter.FieldsMapper
  fields_mapper.setEventListeners()




