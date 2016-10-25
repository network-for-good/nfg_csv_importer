class NfgCsvImporter.IgnoreColumn
  constructor: (@el) ->
    # Elements
    @checkboxes = @el.find "input[type='checkbox']"
    @selects = @el.find "select"

    # Component Library
    @columnSelector = ".col-importer"
    @ignoreColumnClass = "col-ignore"
    @ignoreColumnSelectOptionValue = "ignore_column"

    # Actions
    @checkboxes.on 'click', (event) =>
      checkbox = $(event.currentTarget)
      @ignoreColumnViaCheckbox(checkbox)

    @selects.on 'change', (event) =>
      select = $(event.currentTarget)
      @evaluateIgnoringColumnViaSelect(select)


  # Checkbox Behavior
  ignoreColumnViaCheckbox: (checkbox) ->
    column = checkbox.closest(@columnSelector)
    select = column.find("select")

    @toggleIgnoreColumn(column)
    @toggleSelectViaCheckbox(select)

  # Toggle Ignore Column
  toggleIgnoreColumn: (column) ->
    column.toggleClass(@ignoreColumnClass)


  # Change the select's option :selected value
  toggleSelectViaCheckbox: (select) ->
    selectVal = select.val()

    if selectVal == @ignoreColumnSelectOptionValue
      select.val("")
    else
      select.val(@ignoreColumnSelectOptionValue)


  evaluateIgnoringColumnViaSelect: (select) ->
    # selectVal = select.val()
    # if selectVal == @ignoreColumnSelectOptionValue
    #   @toggleIgnoreColumn(select)




$(document).on 'ready', ->
  el = $(".col-importer")
  return unless el.length > 0
  inst = new NfgCsvImporter.IgnoreColumn el
