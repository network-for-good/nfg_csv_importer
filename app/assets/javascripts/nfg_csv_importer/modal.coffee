$(document).on 'turbolinks:load', ->



  $("a[data-toggle='modal']").click ->
    $("[data-modal-identifier='nfg_csv_importer_modal']").appendTo "body"
    $("body").addClass "interstitial-open"
    $("[data-modal-identifier='nfg_csv_importer_modal']").wrap "<div class='nfg-csv-importer'></div>"


  # $("[data-modal-identifier='nfg_csv_importer_modal']").on 'shown.bs.modal', (e) ->

  #   $(".modal-backdrop").addClass "nfg-csv-importer"
