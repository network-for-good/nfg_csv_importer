class NfgCsvImporter.HighlightInteractedColumn
  constructor: (@el) ->

    # Page Component Library
    @checkboxSelector = "input[type='checkbox']"
    @columnSelector = ".col-importer"
    @highlightColumnClass = "card-importer-success"

    # Elements
    @checkboxes = @el.find @checkboxSelector
    @selects = @el.find "select"


    @checkboxes.on 'click', (event) =>
      checkbox = $(event.target)

      # Start the process and initialize the auto save animations
      @initHighlightColumn(checkbox)


    # On change of a select menu, launch autosave notification
    @selects.on 'change', (event) =>
      select = $(event.target)

      # Start the process and initialize the auto save animations
      @initHighlightColumn(select)



  # SOMETIMES AFTER RAPID CLICKING, THE FUNCTION STOPS FIRING PERMANENTLY
  initHighlightColumn: (clickedElement) ->
    @highlightColumn(clickedElement)




  # Highlight the interacted column (card)
  highlightColumn: (clickedElement) ->
    console.log "started highlight column function from " + clickedElement.attr "name"
    # Store the animation ending values for ease of adjustment
    animationEnd = "webkitAnimationEnd oAnimationEnd msAnimationEnd animationend"

    # Determine which column (card) to attach the highlight to
    columnCard = clickedElement.closest @columnSelector

    # Run the column (card) highlight animation
    columnCard.addClass(@highlightColumnClass).on animationEnd, ->

      # Remove the column (card) highlight animation class once the animation is over
      $(@).removeClass(@highlightColumnClass)

$(document).on 'turbolinks:load', ->
  el = $(".col-importer")
  return unless el.length > 0
  inst = new NfgCsvImporter.HighlightInteractedColumn el
