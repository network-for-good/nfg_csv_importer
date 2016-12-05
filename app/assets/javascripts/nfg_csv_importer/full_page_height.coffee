$(document).on NfgCsvImporter.readyOrTurboLinksLoad, ->
  fullPageDiv = $("[data-set-full-page='true']")
  fullPageDivBeginsAtY = fullPageDiv.offset().top
  setFullPageDivHeightTo = $(window).height() - fullPageDivBeginsAtY

  fullPageDiv.height(setFullPageDivHeightTo)

