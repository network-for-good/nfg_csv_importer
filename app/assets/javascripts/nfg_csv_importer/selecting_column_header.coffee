# Purpose: Deliver the interaction of the impact of selecting
# a column header from the dropdown menu, seperate from ignoring

class NfgCsvImporter.SelectingColumnHeader
  constructor: (@el) ->

$(document).on 'turbolinks:load', ->
  el = $(".col-importer")
  return unless el.length > 0
  inst = new NfgCsvImporter.SelectingColumnHeader el
