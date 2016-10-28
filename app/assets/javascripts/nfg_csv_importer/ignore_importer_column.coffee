# Purpose: Deliver the interaction design for ignoring a column
# by checkbox or selecting from the dropdown menu

class NfgCsvImporter.IgnoreImporterColumn
  constructor: (@el) ->
    # Component Library
    @checkboxSelector = "input[type='checkbox']"
    @columnSelector = ".col-importer"
    @cardSelector = ".card"
    @ignoreCardClass = "card-disabled"
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
    @selects.on 'change', (event) =>
      select = $(event.currentTarget)
      @evaluateIgnoringColumnViaSelect(select)


  # Checkbox Behavior
  ignoreColumnViaCheckbox: (checkbox) ->
    column = checkbox.closest @columnSelector
    card = column.find @cardSelector
    select = column.find("select")

    # Toggle ignore css class
    @toggleIgnoreColumn(card, select)

    # Set the select's option :selected value to ignore if appropriate
    @toggleSelectViaCheckbox(select)


  # Toggle Ignore Column
  toggleIgnoreColumn: (card, select) ->
    # Toggle ignore class
    card.toggleClass @ignoreCardClass

    # Toggle disabled class (fallback) & disabled attribute
    select.toggleClass("disabled").attr "disabled", (_, attr) ->
      !attr

    # Prevent select menu from being clickable once ignore is set.
    if card.hasClass @ignoreCardClass
      select.mousedown ->
        event.preventDefault()

    # If ignore class is removed, undo the preventDefault
    else
      select.unbind('mousedown')


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
    card = select.closest @cardSelector
    checkbox = select.closest(@columnSelector).find(@checkboxSelector)

    # If the column is set to ignored via the select menu, toggle the ignore checkbox
    # & fire the toggle function
    if selectVal == @ignoreColumnSelectOptionValue
      checkbox.prop "checked", true

      @toggleIgnoreColumn(card, select)


$(document).on 'turbolinks:load', ->
  el = $(".col-importer")
  return unless el.length > 0
  inst = new NfgCsvImporter.IgnoreImporterColumn el
