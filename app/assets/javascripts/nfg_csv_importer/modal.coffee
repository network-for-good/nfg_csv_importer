$(document).on 'turbolinks:load', ->


  $("a[data-toggle='modal']").click ->
    $("#nfg_csv_importer_modal").appendTo "body"

  $('#nfg_csv_importer_modal').on 'hidden.bs.modal', (e) ->
    $("#nfg_csv_importer_modal").remove()

