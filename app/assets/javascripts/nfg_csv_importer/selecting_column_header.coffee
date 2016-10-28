# Purpose: Deliver the interaction of the impact of selecting
# a column header from the dropdown menu, seperate from ignoring

class NfgCsvImporter.SelectingColumnHeader
  constructor: (@el) ->
    # Component Library
    @columnSelector = ".col-importer"
    @ignoreColumnSelectOptionValue = "ignore_column"
    @form = "#self_importer form"

    # Elements
    @selects = @el.find "select"
    @columnHeaderNameSelectors = "[data-describe='source-column-header-name']"

    # Actions
    # Check for ignoring the column based on the select menu interaction
    @selects.on 'change', (event) =>
      select = $(event.currentTarget)

      # Pavan: here!
      # $(@form).submit()

      @evaluateColumnHeaderInteraction(select)

  evaluateColumnHeaderInteraction: (select) =>
    column = select.closest @columnSelector
    columnHeaderNameSelector = column.find @columnHeaderNameSelectors
    selectVal = select.val()

    # if selectVal == @ignoreColumnSelectOptionValue
    #   columnHeaderNameSelector.unwrap()
    # else
    columnHeaderNameSelector.wrapInner "<s class='text-muted'></s>"

$(document).on 'turbolinks:load', ->
  el = $(".col-importer")
  return unless el.length > 0
  inst = new NfgCsvImporter.SelectingColumnHeader el
