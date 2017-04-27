class NfgCsvImporter.SmoothScroll
  constructor: (@el) ->
    @dataTargetAttribute = "smooth-scroll-target"
    @offset = @el.data "smooth-scroll-offset"

    @el.click (event) =>
      event.preventDefault
      clickedElement = $(event.currentTarget)
      @smoothScrollTo(clickedElement, @offset)

  smoothScrollTo: (clickedElement, offset) ->
    @offset ||= 0
    destinationToScrollTo = $($(clickedElement).data @dataTargetAttribute)

    $("body").animate {
        scrollTop: destinationToScrollTo.offset().top - 49 - @offset
    }, 1000

$(document).on NfgCsvImporter.readyOrTurboLinksLoad, ->
  el = $("[data-smooth-scroll-target]")
  return unless el.length > 0
  inst = new NfgCsvImporter.SmoothScroll el


