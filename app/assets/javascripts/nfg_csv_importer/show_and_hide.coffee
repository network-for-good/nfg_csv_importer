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
    fadeOutPreference = $(clickedElement).data "fade-out"

    if fadeOutPreference == true
      $(clickedElement).fadeTo 300, 0
      $(clickedElement).css "pointer-events", "none"
    elementToTarget.slideToggle 300, ->
      $(@).data "show-hide", "show"


$(document).on 'ready page:load', ->
  el = $("[data-show-hide-target]")

  # Turbolinks doesn't refresh the page; re-displays faded out elements, fix that here:
  $("[data-fade-out='true']").css { "opacity" : 1, "pointer-events" : "auto" }

  return unless el.length > 0
  inst = new NfgCsvImporter.ShowAndHide el
