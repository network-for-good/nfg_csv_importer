$(document).on 'turbolinks:load', ->

  $("a.text-glow").click ->
    if($('.nfg-csv-importer').attr('data-unmapped-highlight') == 'enabled')
      new_highlight_status = 'disabled'
    else
      new_highlight_status =  'enabled'
    $('.nfg-csv-importer').attr('data-unmapped-highlight', new_highlight_status)
    $("#highlights_off").toggle()
    $("#highlights_on").toggle()
    $(".card[data-mapped='false']").each ->
      $(@).toggleClass "card-highlight"

