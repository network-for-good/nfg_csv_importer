# Purpose: Deliver the interaction of the impact of selecting
# a column header from the dropdown menu, seperate from ignoring

class NfgCsvImporter.SelectingColumnHeader
  constructor: (@el) ->
    # Component Library
    @columnSelector = ".col-importer"
    @ignoreColumnSelectOptionValue = "ignore_column"

    # Elements
    @selects = @el.find "select"
    @columnHeaderNameSelectors = "[data-describe='source-column-header-name']"
    # @selectsValue = @el.find "select option:selected"

    # Actions
    # Check for ignoring the column based on the select menu interaction
    @selects.on 'change', (event) =>
      select = $(event.target)
      @evaluateColumnHeaderInteraction(select)

  evaluateColumnHeaderInteraction: (select) =>
    column = select.closest @columnSelector
    columnHeaderNameSelector = column.find @columnHeaderNameSelectors

    # Conditions to test against:
    # Ignore suite:
    # 1. When a column header is already updated, upon ignore checkbox or select option
    #    de-strike out.
    # 2. When un-ignored and reset back to the empty select option, un-strike out

    # Next to test:
    # 3. Struck out by picking a column header, then going back to empty select should de-strike out
    #    and add back the notification icon

    columnHeaderNameSelector.wrapInner "<s class='text-muted'></s>"


    # Features to introduce:
    # 1. Add updated badge to a column that had the header selected.
    # 1b. Remove the badge is the column is reset... consider writing a "wipe all"
    #     kind of function on emptying the header select











$(document).on 'turbolinks:load', ->
  el = $(".col-importer")
  return unless el.length > 0
  inst = new NfgCsvImporter.SelectingColumnHeader el
