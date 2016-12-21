class NfgCsvImporter.FullPageHeight
  constructor: (@el) ->
    @fullPageDivBeginsAtY = @el.offset().top
    @setFullPageDivHeightTo = $(window).height() - @fullPageDivBeginsAtY
    @el.height(@setFullPageDivHeightTo)

$(document).on NfgCsvImporter.readyOrTurboLinksLoad, ->
  el = $("[data-set-full-page='true']")
  return unless el.length > 0
  inst = new NfgCsvImporter.FullPageHeight el
