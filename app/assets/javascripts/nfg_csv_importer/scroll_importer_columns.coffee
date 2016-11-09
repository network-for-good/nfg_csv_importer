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



  $('a.btn-horizontal-scroll').on click: (e) ->

    e.preventDefault()

    centerScrollLeft = ($('.container-importer').width() / 2)
    target = $(@).attr('href')
    card = $(target).closest ".card"

    cardPositionRelativeToDocument = $(target).closest(".card").offset().left - 200 #the width of the side nav
    actualCardOffsetLeft = Math.abs( $('#fields_mapping').offset().left - 200 )
    centerOnTheFocusedCard = (actualCardOffsetLeft + cardPositionRelativeToDocument) - centerScrollLeft + 200


    $(".card").removeClass "card-duplicate"
    $(card).addClass "card-duplicate"

    $("body").animate {
      scrollTop: $("#thing").offset().top - 100
    }, 500


    setTimeout (->
      $(".container-importer").animate {
        scrollLeft: centerOnTheFocusedCard
        scrollTop: $(target).offset().top
      }, 1100
    ), 500

    setTimeout (->
      $(card).removeClass "card-duplicate"
    ), 2500

