class NfgCsvImporter.HorizontalScroller
  @IMPORT_CONTAINER_CLASS: ".container-importer"
  @SCROLL_BUTTONS_FINDER: "a.horizontal-scroll-btn"
  @MAPPING_FORM: "#fields_mapping"
  @DUPLICATE_CARD_CLASS: "card-duplicate"
  @COLUMN_WRAPPER_ID: "#columns_wrapper"
  @CARD_CLASS: ".card"

  constructor: () ->
    @columnsWrapper = $(HorizontalScroller.COLUMN_WRAPPER_ID)

    @rightScrollButton = $("[data-horizontal-scroll-button='right']")
    @leftScrollButton = $("[data-horizontal-scroll-button='left']")
    @duplicateMappedButton = $('a.btn-horizontal-scroll')

  setEventListeners: () ->
    @rightScrollButton.click ->
      event.preventDefault()
      $(HorizontalScroller.IMPORT_CONTAINER_CLASS).animate { scrollLeft: '+=900px', "easeInOut" }, 550

    @leftScrollButton.click ->
      event.preventDefault()
      $(HorizontalScroller.IMPORT_CONTAINER_CLASS).animate { scrollLeft: '-=900px', "easeInOut" }, 550

    @columnsWrapper.on 'mouseenter', ->
      $(HorizontalScroller.SCROLL_BUTTONS_FINDER).addClass "active"

    @columnsWrapper.on 'mouseleave', ->
      $(HorizontalScroller.SCROLL_BUTTONS_FINDER).addClass "active-out"
      $(HorizontalScroller.SCROLL_BUTTONS_FINDER).removeClass "active"
      setTimeout(( ->
        $(HorizontalScroller.SCROLL_BUTTONS_FINDER).removeClass "active-out"
      ), 300)

    @setDuplicateMappedButtonListeners()

  setDuplicateMappedButtonListeners: () ->
    @duplicateMappedButton.on click: (e) ->
      e.preventDefault()

      centerScrollLeft = ($(HorizontalScroller.IMPORT_CONTAINER_CLASS).width() / 2)
      target = $(@).attr('href')
      card = $(target).closest HorizontalScroller.CARD_CLASS

      cardPositionRelativeToDocument = $(target).closest(HorizontalScroller.CARD_CLASS).offset().left - 200 #the width of the side nav
      actualCardOffsetLeft = Math.abs( $(HorizontalScroller.MAPPING_FORM).offset().left - 200 )
      centerOnTheFocusedCard = (actualCardOffsetLeft + cardPositionRelativeToDocument) - centerScrollLeft + 200


      $(HorizontalScroller.CARD_CLASS).removeClass HorizontalScroller.DUPLICATE_CARD_CLASS
      $(card).addClass HorizontalScroller.DUPLICATE_CARD_CLASS

      $("body").animate {
        scrollTop: $(HorizontalScroller.COLUMN_WRAPPER_ID).offset().top - 100
      }, 500


      setTimeout (->
        $(HorizontalScroller.IMPORT_CONTAINER_CLASS).animate {
          scrollLeft: centerOnTheFocusedCard
          scrollTop: $(target).offset().top
        }, 1100
      ), 500

      setTimeout (->
        $(card).removeClass HorizontalScroller.DUPLICATE_CARD_CLASS
      ), 2500
