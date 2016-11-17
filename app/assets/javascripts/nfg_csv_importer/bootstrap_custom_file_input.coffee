$(document).on 'turbolinks:load', ->
  $('input[type=\'file\']').change ->
    fieldVal = $(this).val()
    myRegexp = /[^\\]*$/g
    filename = fieldVal.match(myRegexp)
    $(this).next('.file-custom').attr 'data-content', filename
