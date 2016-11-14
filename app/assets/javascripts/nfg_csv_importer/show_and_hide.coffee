class NfgCsvImporter.ShowAndHide
  constructor: (@el) ->
    @dataTargetAttribute = "show-hide-target"
    @dataToggleClassAttribute = "show-hide-toggle-class"
    @hiddenElementsByDefault = $("[data-show-hide='hide']")

    @hiddenElementsByDefault.hide()

    @el.on 'click', (event) =>
      event.preventDefault
      clickedElement = $(event.currentTarget)
      @toggleShowHide(clickedElement)

  toggleShowHide: (clickedElement) ->
    elementToTarget = $($(clickedElement).data @dataTargetAttribute)
    classToToggle = $(clickedElement).data @dataToggleClassAttribute

    elementToTarget.slideToggle 300, ->
      $(@).data "show-hide", "show"

$(document).on 'turbolinks:load', ->
  el = $("[data-show-hide-target][data-show-hide-toggle-class]")
  return unless el.length > 0
  inst = new NfgCsvImporter.ShowAndHide el
