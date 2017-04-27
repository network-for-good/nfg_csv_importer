class NfgCsvImporter.UploadForm
  constructor: (@el) ->
    # Form
    @form = @el.closest 'form'
    @formGroup = @el.closest('form-group')
    @button = @form.find "button[type='submit']"

    # Errors
    @errorContainer = @el.next "[data-toggle='error']"
    @error = "<strong>Shoot!</strong> You can only upload <strong>csv, xls, or xlsx</strong> files."
    @errorClasses = 'text-inverse'
    @tooltip = @button.closest "span[data-toggle='tooltip']"

    @el.on 'change', (e) =>
      @beginValidation e

  beginValidation: (e) ->
    if @el.val().length # a file was chosen
      @addTooltip()
      @validateFileType()

    else if (e.which == 27) || (@el.val().length == 0)
      @errorContainer.html ''
      @el
        .attr 'aria-invalid', 'false'
        .closest '.form-group'
        .removeClass 'has-danger'

      @addTooltip()
      @disableButton()

  validateFileType: ->
    fileType = [
      'csv'
      'xls'
      'xlsx'
    ]
    if $.inArray( @el
                    .val()
                    .split('.')
                    .pop()
                    .toLowerCase(), fileType) == -1

      @validationFailure()
      return false

    else
      @validationSuccess()

  validationFailure: ->
    @el
      .attr 'aria-invalid', 'true'
      .closest '.form-group'
      .addClass 'has-danger'
    @errorContainer
      .addClass @errorClasses
      .html @error

    unless @button.hasClass 'disabled'
      $(@tooltip).tooltip('hide')

    @disableButton()

  validationSuccess: ->
    @el
      .attr 'aria-invalid', 'false'
      .closest '.form-group'
      .removeClass 'has-danger'
    @errorContainer.html ''

    @enableButton()
    @removeTooltip()

  enableButton: ->
    @button
      .removeClass 'disabled'
      .attr 'disabled', false

  disableButton: ->
    @button
      .addClass 'disabled'
      .attr 'disabled', true

  removeTooltip: ->
    @tooltip.tooltip('dispose')
    $('[data-toggle="tooltip"]').on 'hidden.bs.tooltip', ->
      $("[data-tooltip-status='present']").remove()

  addTooltip: ->
    @tooltip.tooltip()
    $('[data-toggle="tooltip"]').on 'show.bs.tooltip', ->
      setTimeout (->
        $('.tooltip').wrap "<span class='importer-gem' data-tooltip-status='present'></div>"
      ), 1   # Simple timeout removes flicker due to wrapping... 'shown.bs.tooltip' generates a flicker.

$(document).on NfgCsvImporter.readyOrTurboLinksLoad, ->
  el = $("input[name='import[import_file]']")

  return unless el.length
  inst = new NfgCsvImporter.UploadForm el
