class CustomFileInput
  constructor: (@el) ->
    @filenameOutput = @el.find '.custom-file-label'
    @input = @el.find '.custom-file-input'

    @input.on 'change', (e) =>
      input = $(e.target)
      @updateFilename(input)

  updateFilename: (input) ->
    @filenameOutput.text filename(input)

  filename = (input) ->
    if input.val()
      input[0].files[0].name
    else
      @filenameOutput.text()

jQuery(document).ready ($) ->
  elSelector = ".custom-file"

  if $(elSelector).length
    $(elSelector).each ->
      inst = new CustomFileInput $(@)

  $('body').on 'bs.modal.show', (e) ->
    if $(elSelector).length
      $(elSelector).each ->
        inst = new CustomFileInput $(@)

  $(document).ajaxComplete (e, xhr, settings) ->
    if $(elSelector).length
      $(elSelector).each ->
        inst = new CustomFileInput $(@)
