$(document).on 'turbolinks:load', ->


  $("a[data-toggle='modal']").click ->
    $("#nfg_csv_importer_modal").appendTo "body"
