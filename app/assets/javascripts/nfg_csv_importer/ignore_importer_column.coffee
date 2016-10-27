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
    # Check for ignoring the column when clicking on the checkbox
    @checkboxes.on 'click', (event) =>
      checkbox = $(event.currentTarget)
      @ignoreColumnViaCheckbox(checkbox)

    # Check for ignoring the column based on the select menu interaction
    # @selects.on 'change', (event) =>
    @selects.on 'change', (event) =>
      select = $(event.currentTarget)
      @evaluateIgnoringColumnViaSelect(select)


  # Checkbox Behavior
  ignoreColumnViaCheckbox: (checkbox) ->
    column = checkbox.closest(@columnSelector)
    select = column.find("select")

    # Toggle ignore css class
    @toggleIgnoreColumn(column, select)

    # Set the select's option :selected value to ignore if appropriate
    @toggleSelectViaCheckbox(select)


  # Toggle Ignore Column
  toggleIgnoreColumn: (column, select) ->
    # Toggle ignore class
    column.toggleClass(@ignoreColumnClass)

    # Prevent select menu from being clickable once ignore is set.
    if column.hasClass @ignoreColumnClass
      $(select).mousedown ->
        event.preventDefault()

    # If ignore class is removed, undo the preventDefault
    else
      $(select).unbind('mousedown')


  # Change the select's option :selected value
  toggleSelectViaCheckbox: (select) ->
    selectVal = select.val()

    # If it was previously ignored, reset the select's option :selected to empty / blank
    if selectVal == @ignoreColumnSelectOptionValue
      select.val("")

    # Otherwise, set it as ignored
    else
      select.val(@ignoreColumnSelectOptionValue)

  # Determine whether or not to move forward with ignoring or unignoring a column
  evaluateIgnoringColumnViaSelect: (select) ->
    selectVal = select.val()
    column = select.closest(@columnSelector)

    # If the column is set to ignored via the select menu, toggle the ignore checkbox
    # & fire the toggle function
    if selectVal == @ignoreColumnSelectOptionValue
      column.find(@checkboxSelector).prop "checked", true
      @toggleIgnoreColumn(column, select)


$(document).on 'ready turbolinks:load', ->
  el = $(".col-importer")
  return unless el.length > 0
  inst = new NfgCsvImporter.IgnoreColumn el
