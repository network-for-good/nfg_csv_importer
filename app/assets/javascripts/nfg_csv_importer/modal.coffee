$(document).on NfgCsvImporter.readyOrTurboLinksLoad, ->
  $("a[data-toggle='modal']").click ->
    $("[data-modal-identifier='nfg_csv_importer_modal']").appendTo "body"
    $("body").addClass "nfg-csv-importer-modal-open"

  $("[data-modal-identifier='nfg_csv_importer_modal']").on 'show.bs.modal', ->
    setTimeout (->
      $("[data-modal-identifier='nfg_csv_importer_modal']").wrap "<span class='nfg-csv-importer' data-modal-status='present'></div>"
    ), 1

    $("[data-modal-identifier='nfg_csv_importer_modal']").on 'hidden.bs.modal', ->
      $("[data-modal-status='present']").remove()
