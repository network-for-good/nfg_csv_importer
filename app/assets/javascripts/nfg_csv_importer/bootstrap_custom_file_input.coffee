$(document).on NfgCsvImporter.readyOrTurboLinksLoad, ->

  # $('.file-custom').attr('data-content').each ->
  #   $(@).previous("input[type=\'file\']")

  $("input[type=\'file\']").change ->
    fieldVal = $(this).val()
    filenames = fieldVal.split("\\")
    $("[data-file='name']").attr 'data-content', filenames[filenames.length-1]
