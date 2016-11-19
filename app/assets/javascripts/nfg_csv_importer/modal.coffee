$(document).on 'ready page:load', ->
  $("a[data-toggle='modal']").click ->
    $("[data-modal-identifier='nfg_csv_importer_modal']").appendTo "body"
    $("body").addClass "interstitial-open"

  $("[data-modal-identifier='nfg_csv_importer_modal']").on 'show.bs.modal', ->
    setTimeout (->
      $("[data-modal-identifier='nfg_csv_importer_modal']").wrap "<div class='nfg-csv-importer' data-modal-flag='on'></div>"
    ), 1

    $("[data-modal-identifier='nfg_csv_importer_modal']").on 'hidden.bs.modal', ->
      # setTimeout (->
      $("[data-modal-flag='on']").remove()
      # ), 100   # Simple timeout removes flicker due to wrapping... 'shown.bs.tooltip' generates a flicker.

    # $("[data-modal-identifier='nfg_csv_importer_modal']").wrap "<div class='nfg-csv-importer'></div>"
