class NfgCsvImporter.IgnoreColumn
  constructor: (@el) ->
    # Component Library
    @checkboxSelector = "input[type='checkbox']"
    @columnSelector = ".col-importer"
    @ignoreColumnClass = "col-ignore"
    @ignoreColumnSelectOptionValue = "ignore_column"

    # Elements
    @checkboxes = @el.find @checkboxSelector
    @selects = @el.find "select"

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

    # Might need this...
    # if column.hasClass @ignoreColumnClass
    #   column.removeClass @ignoreColumnClass
    # else
    #   column.addClass @ignoreColumnClass

  # Change the select's option :selected value
  toggleSelectViaCheckbox: (select) ->
    selectVal = select.val()

    if selectVal == @ignoreColumnSelectOptionValue
      select.val("")
    else
      select.val(@ignoreColumnSelectOptionValue)

  # Determine whether or not to move forward with ignoring or unignoring a column
  evaluateIgnoringColumnViaSelect: (select) ->
    selectVal = select.val()
    column = select.closest(@columnSelector)

    if selectVal == @ignoreColumnSelectOptionValue
      column.find(@checkboxSelector).prop "checked", true
      @toggleIgnoreColumn(column)
      select.preventDefault
    # Goal of this: if I have ignore applied, but change it to something else
    # De-ignore the column, remove the class.
    # else
    #   column.find(@checkboxSelector).prop "checked", false




$(document).on 'ready', ->
  el = $(".col-importer")
  return unless el.length > 0
  inst = new NfgCsvImporter.IgnoreColumn el
