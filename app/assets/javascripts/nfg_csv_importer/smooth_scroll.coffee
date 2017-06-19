class NfgCsvImporter.SmoothScroll
  constructor: (@el) ->
    @dataTargetAttribute = "smooth-scroll-target"

    @el.click (e) =>
      e.preventDefault
      clickedElement = $(e.currentTarget)
      @smoothScrollTo clickedElement

  smoothScrollTo: (clickedElement) ->
    destinationToScrollTo = $($(clickedElement).data @dataTargetAttribute)

    $("body").animate {
        scrollTop: destinationToScrollTo.offset().top - 49
    }, 600

$(document).on NfgCsvImporter.readyOrTurboLinksLoad, ->
  el = $("[data-smooth-scroll-target]")
  return unless el.length > 0
  inst = new NfgCsvImporter.SmoothScroll el


