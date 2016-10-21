class NfgCsvImporter.IgnoreColumn
  constructor: (@column) ->



$(document).on 'ready', ->
  column = $('.col-importer')
  return unless column.length > 0
  inst = new NfgCsvImporter.IgnoreColumn column
