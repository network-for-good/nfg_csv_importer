class NfgCsvImporter.ShowAndHide
  constructor: (@el) ->
    @dataTargetAttribute = "show-hide-target"
    @hiddenElementsByDefault = $("[data-show-hide='hide']")
    @hiddenElementsByDefault.hide()

    @el.click (event) =>
      event.preventDefault
      clickedElement = $(event.currentTarget)
      @toggleShowHide(clickedElement)

  toggleShowHide: (clickedElement) ->
    elementToTarget = $($(clickedElement).data @dataTargetAttribute)

    elementToTarget.slideToggle 300, ->
      $(@).data "show-hide", "show"
      if $(clickedElement).data "fade-out", true
        $(clickedElement).fadeTo 500, 0
        $(clickedElement).css "pointer-events", "none"


$(document).on 'turbolinks:load', ->
  el = $("[data-show-hide-target]")

  # Turbo links doesn't refresh the page; re-displays faded out elements
  $("[data-fade-out='true']").css { "opacity" : 1, "pointer-events" : "auto" }

  return unless el.length > 0
  inst = new NfgCsvImporter.ShowAndHide el
