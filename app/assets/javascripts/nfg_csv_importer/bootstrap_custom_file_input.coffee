$(document).on 'ready page:load', ->
  $("input[type=\'file\']").change ->
    fieldVal = $(this).val()
    filenames = fieldVal.split("\\")
    $(this).next('.file-custom').attr 'data-content', filenames[filenames.length-1]
