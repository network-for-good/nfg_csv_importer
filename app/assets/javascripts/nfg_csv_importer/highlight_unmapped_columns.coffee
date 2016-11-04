$(document).on 'turbolinks:load', ->

  $("#highlight_on").hide()
  $("a.text-glow").click ->
    $("#highlight_off").toggle()
    $("#highlight_on").toggle()
    $(".card[data-mapped='false']").each ->
      $(@).toggleClass "card-highlight"

