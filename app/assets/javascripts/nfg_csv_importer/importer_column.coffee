class NfgCsvImporter.IgnoreColumn
  constructor: (@el) ->
    # Elements
    @checkbox = @el.find "input[type='checkbox']"

    # Component Library
    columnClass = ".col-importer"
    ignoreColumnClass = "col-ignore"
    ignoreColumnSelectOptionValue = "ignore_column"

    @checkbox.on 'click', ->
      $(@).closest(columnClass).toggleClass(ignoreColumnClass)

$(document).on 'ready', ->
  el = $(".col-importer")
  return unless el.length > 0
  inst = new NfgCsvImporter.IgnoreColumn el
