$(document).on 'turbolinks:load', ->

  $("[data-horizontal-scroll-button='right']").click ->
    event.preventDefault()
    $('.container-importer').animate { scrollLeft: '+=585px', "easeInOut" }, 550

  $("[data-horizontal-scroll-button='left']").click ->
    event.preventDefault()
    $('.container-importer').animate { scrollLeft: '-=585px', "easeInOut" }, 550

  $("#thing").on 'mouseenter', ->
    $(".horizontal-scroll-btn").addClass "active"
    # $(".horizontal-scroll-btn").removeClass "active-out"

  $("#thing").on 'mouseleave', ->
    $(".horizontal-scroll-btn").addClass "active-out"
    $(".horizontal-scroll-btn").removeClass "active"

    setTimeout(( ->

      $(".horizontal-scroll-btn").removeClass "active-out"
    ), 300)
