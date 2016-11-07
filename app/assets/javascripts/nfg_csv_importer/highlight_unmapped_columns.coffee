class NfgCsvImporter.ToggleUnmappedHighlights
  constructor: () ->
    @importerPage = $('.nfg-csv-importer')
    @highlightsStatus = @importerPage.attr('data-unmapped-highlight')
    # the id indicates the status of the switch
    @turnHighlightsOffSwitch = $("#turn_highlights_off")
    @turnHighlightsOnSwitch = $("#turn_highlights_on")

  toggleHighlights: () ->
    if @highlightsStatus == 'enabled'
      new_highlight_status = 'disabled'
    else
      new_highlight_status =  'enabled'

    # update the status of the highligh flag
    @importerPage.attr('data-unmapped-highlight', new_highlight_status)

    # display or remove the highlights based on the status set above
    @setHighlightsBasedOnStatus()

  setHighlightsBasedOnStatus: () ->
    # get the current highlight status, since it may have changed
    @unMappedColumns = $(".card[data-mapped='false']")
    @highlightsStatus = @importerPage.attr('data-unmapped-highlight')
    if @highlightsStatus == 'enabled'
      @turnHighlightsOnSwitch.hide()
      @turnHighlightsOffSwitch.show()
      @unMappedColumns.each ->
        unless $(@).hasClass("card-highlight")
          $(@).addClass("card-highlight")
    else
      @turnHighlightsOnSwitch.show()
      @turnHighlightsOffSwitch.hide()
      @unMappedColumns.each ->
        if $(@).hasClass("card-highlight")
          $(@).removeClass "card-highlight"

$(document).on 'turbolinks:load', ->
  $("a.text-glow").click ->
    highlighter = new NfgCsvImporter.ToggleUnmappedHighlights
    highlighter.toggleHighlights()
