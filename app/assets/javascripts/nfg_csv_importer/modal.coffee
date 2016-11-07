$(document).on 'turbolinks:load', ->



  $("a[data-toggle='modal']").click ->
    $("[data-modal-identifier='nfg_csv_importer_modal']").appendTo "body"
    $("body").addClass "interstitial-open"
