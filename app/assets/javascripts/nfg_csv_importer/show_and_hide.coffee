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

$(document).on 'turbolinks:load', ->
  el = $("[data-show-hide-target]")
  return unless el.length > 0
  inst = new NfgCsvImporter.ShowAndHide el
