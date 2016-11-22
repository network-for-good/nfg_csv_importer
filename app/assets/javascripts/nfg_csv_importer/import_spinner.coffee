$(document).on NfgCsvImporter.readyOrTurboLinksLoad, ->
  $('#new_import_service').submit ->
    $('<div id="overlay"> </div>').appendTo document.body
    $('#spinner').show()
    return
  $('#spinner').hide()
  return
