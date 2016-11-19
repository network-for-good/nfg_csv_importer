class NfgCsvImporter.SmoothScroll
  constructor: (@el) ->
    @dataTargetAttribute = "smooth-scroll-target"

    @el.click (event) =>
      event.preventDefault
      clickedElement = $(event.currentTarget)
      @smoothScrollTo(clickedElement)

  smoothScrollTo: (clickedElement) ->
    destinationToScrollTo = $($(clickedElement).data @dataTargetAttribute)

    $("body").animate {
        scrollTop: destinationToScrollTo.offset().top - 49
    }, 1000

$(document).on 'ready page:load', ->
  el = $("[data-smooth-scroll-target]")
  return unless el.length > 0
  inst = new NfgCsvImporter.SmoothScroll el


