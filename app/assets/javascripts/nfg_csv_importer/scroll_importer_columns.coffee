$(document).on 'turbolinks:load', ->
  centerScrollLeft = ($('.container-importer').width() / 2)


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




  $('a.btn-horizontal-scroll').on click: (e) ->

    e.preventDefault()

    target = $(this).attr('href')
    # returns something like #card_header_etc
    card = $(target)
    root = $('.container-importer')
    xPosition = $(card).offset().left
    horizontalPosition = card.scrollLeft()

    console.log "card is " + card.attr "id"
    console.log "link target is " + $(this).attr('href')
    console.log "card.offset().left is " + xPosition
    console.log "card.scrollLeft() is " + horizontalPosition

    $(".card").removeClass("card-duplicate")
    $(card).addClass "card-duplicate"

    $("body").animate {
      scrollTop: $("#thing").offset().top - 100
    }, 500

    # if horizontalPosition == 0
    #   return
    #   console.log $(target).offset().left()




    setTimeout (->
      root.animate {
        scrollLeft: $(target).offset().left - centerScrollLeft
        scrollTop: $(target).offset().top
      }, 1100
    ), 500




