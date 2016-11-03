$(document).on 'turbolinks:load', ->

  $("[data-horizontal-scroll-button='right']").click ->
    event.preventDefault()
    $('.container-importer').animate { scrollLeft: '+=650px', "easeInOut" }, 600

  $("[data-horizontal-scroll-button='left']").click ->
    event.preventDefault()
    $('.container-importer').animate { scrollLeft: '-=650px', "easeInOut" }, 600

  $("#thing").on 'mouseenter', ->
    $(".horizontal-scroll-btn").addClass "active"
    # $(".horizontal-scroll-btn").removeClass "active-out"

  $("#thing").on 'mouseleave', ->
    $(".horizontal-scroll-btn").addClass "active-out"
    $(".horizontal-scroll-btn").removeClass "active"

    setTimeout(( ->

      $(".horizontal-scroll-btn").removeClass "active-out"
    ), 300)

