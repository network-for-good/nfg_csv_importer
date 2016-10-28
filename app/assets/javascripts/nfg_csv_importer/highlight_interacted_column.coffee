class NfgCsvImporter.HighlightInteractedColumn
  constructor: (@el) ->

    # Page Component Library
    @checkboxSelector = "input[type='checkbox']"
    @columnSelector = ".col-importer"
    @cardSelector = ".card"
    @highlightColumnClass = "card-highlight"
    @transitionTimer = 1000

    # Elements
    @checkboxes = @el.find @checkboxSelector
    @selects = @el.find "select"


    @checkboxes.on 'click', (event) =>
      checkbox = $(event.currentTarget)
      highlightableCard = checkbox.parent("label").next(@cardSelector)

      # Start the process and initialize the auto save animations
      @highlightColumn(highlightableCard)


    # On change of a select menu, launch autosave notification
    @selects.on 'change', (event) =>
      select = $(event.currentTarget)
      highlightableCard = select.closest @cardSelector
      # highlightableCard.removeClass("card-highlight")
      # Start the process and initialize the auto save animations
      @highlightColumn(highlightableCard)



  # Highlight the interacted column (card)
  highlightColumn: (highlightableCard) ->
    highlightableCard.addClass("card-highlight").delay(@transitionTimer).queue ->
      $(@).removeClass("card-highlight").dequeue()
      return

$(document).on 'turbolinks:load', ->
  el = $(".col-importer")
  return unless el.length > 0
  inst = new NfgCsvImporter.HighlightInteractedColumn el
