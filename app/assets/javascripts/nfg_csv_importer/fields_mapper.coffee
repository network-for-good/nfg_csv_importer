class NfgCsvImporter.FieldsMapper
  @MAIN_CONTAINER_CLASS: ".nfg-csv-importer"
  @IMPORT_CONTAINER_CLASS: ".container-importer"
  @SCROLL_BUTTONS_FINDER: "a.horizontal-scroll-btn"
  @DUPLICATE_SCROLL_BUTTON_FINDER: "a.btn-horizontal-scroll"
  @MAPPING_FORM: "#fields_mapping"
  @DUPLICATE_CARD_CLASS: "card-duplicate"
  @COLUMN_WRAPPER_ID: "#columns_wrapper"
  @COLUMN_CLASS: ".col-importer"
  @CARD_CLASS: ".card"
  @TURN_HIGHLIGHT_OFF_ID: "#turn_highlights_off"
  @TURN_HIGHLIGHT_ON_ID: "#turn_highlights_on"
  @HIGHLIGHT_STATUS_ELEMENT: "data-unmapped-highlight"
  @CARD_HIGHLIGHT_CLASS: "card-highlight"
  @HEADER_STATS_AREA_SELECTOR: "#importer_header_stats"
  @ERROR_AREA_SELECTOR: "#importer_errors"


  constructor: () ->
    @importerPage = $(FieldsMapper.MAIN_CONTAINER_CLASS)
    @columnsWrapper = $(FieldsMapper.COLUMN_WRAPPER_ID)

    # Scroll related elements
    @rightScrollButton = $("[data-horizontal-scroll-button='right']")
    @leftScrollButton = $("[data-horizontal-scroll-button='left']")

    # Highlight related elements
    @highlightsStatus = @importerPage.attr(FieldsMapper.HIGHLIGHT_STATUS_ELEMENT)
    @turnHighlightsOffSwitch = $(FieldsMapper.TURN_HIGHLIGHT_OFF_ID)
    @turnHighlightsOnSwitch = $(FieldsMapper.TURN_HIGHLIGHT_ON_ID)

    @form = $(FieldsMapper.COLUMN_WRAPPER_ID)

  setEventListeners: () ->

    # scroll control
    @rightScrollButton.click ->
      event.preventDefault()
      $(FieldsMapper.IMPORT_CONTAINER_CLASS).animate { scrollLeft: '+=650px', "easeInOut" }, 600

    @leftScrollButton.click ->
      event.preventDefault()
      $(FieldsMapper.IMPORT_CONTAINER_CLASS).animate { scrollLeft: '-=650px', "easeInOut" }, 600

    @columnsWrapper.on 'mouseenter', ->
      $(FieldsMapper.SCROLL_BUTTONS_FINDER).addClass "active"

    @columnsWrapper.on 'mouseleave', ->
      $(FieldsMapper.SCROLL_BUTTONS_FINDER).addClass "active-out"
      $(FieldsMapper.SCROLL_BUTTONS_FINDER).removeClass "active"
      setTimeout(( ->
        $(FieldsMapper.SCROLL_BUTTONS_FINDER).removeClass "active-out"
      ), 300)

    columns = $(FieldsMapper.COLUMN_CLASS)
    return unless columns.length > 0
    fieldsMapper = new NfgCsvImporter.FieldsMapper
    for column in columns
      fieldsMapper.setEventsOnImportColumn column

    # scroll to duplicate mapped buttond
    @setDuplicateMappedButtonListeners()

  # Toggles unmapped fields highlighter
  toggleHighlights: () ->
    if @highlightsStatus == 'enabled'
      new_highlight_status = 'disabled'
    else
      new_highlight_status =  'enabled'

    # update the status of the highligh flag
    @importerPage.attr('data-unmapped-highlight', new_highlight_status)

    # display or remove the highlights based on the status set above
    @setHighlightsBasedOnStatus()


  # Turns highlights on updated columns based on the status of the
  # highlight flag. Used when a column header is replaced
  # after being updated
  setHighlightsBasedOnStatus: () ->
    # get the current highlight status, since it may have changed
    @unMappedColumns = $(".card[data-mapped='false']")
    @highlightsStatus = @importerPage.attr('data-unmapped-highlight')
    if @highlightsStatus == 'enabled'
      @turnHighlightsOnSwitch.hide()
      @turnHighlightsOffSwitch.show()
      @unMappedColumns.each ->
        unless $(@).hasClass(FieldsMapper.CARD_HIGHLIGHT_CLASS)
          $(@).addClass(FieldsMapper.CARD_HIGHLIGHT_CLASS)
    else
      @unMappedColumns.each ->
        if $(@).hasClass(FieldsMapper.CARD_HIGHLIGHT_CLASS)
          $(@).removeClass FieldsMapper.CARD_HIGHLIGHT_CLASS


  setDuplicateMappedButtonListeners: () ->
    $(FieldsMapper.DUPLICATE_SCROLL_BUTTON_FINDER).on click: (e) ->
      e.preventDefault()

      centerScrollLeft = ($(FieldsMapper.IMPORT_CONTAINER_CLASS).width() / 2)
      target = $(@).attr('href')
      card = $(target).closest FieldsMapper.CARD_CLASS

      cardPositionRelativeToDocument = $(target).closest(FieldsMapper.CARD_CLASS).offset().left - 200 #the width of the side nav
      actualCardOffsetLeft = Math.abs( $(FieldsMapper.MAPPING_FORM).offset().left - 200 )
      centerOnTheFocusedCard = (actualCardOffsetLeft + cardPositionRelativeToDocument) - centerScrollLeft + 200


      $(FieldsMapper.CARD_CLASS).removeClass FieldsMapper.DUPLICATE_CARD_CLASS
      $(card).addClass FieldsMapper.DUPLICATE_CARD_CLASS

      $("body").animate {
        scrollTop: $(FieldsMapper.COLUMN_WRAPPER_ID).offset().top - 100
      }, 500


      setTimeout (->
        $(FieldsMapper.IMPORT_CONTAINER_CLASS).animate {
          scrollLeft: centerOnTheFocusedCard
          scrollTop: $(target).offset().top
        }, 1100
      ), 500

      setTimeout (->
        $(card).removeClass FieldsMapper.DUPLICATE_CARD_CLASS
      ), 2500

  setEventsOnImportColumn: (el) ->
    @column = $(el)
    @checkbox = @column.find "input[type='checkbox']"
    @select = @column.find "select"
    @edit_column =  @column.find "a[data-edit-column='true']"
    @form = $(FieldsMapper.MAPPING_FORM)

    @checkbox.on 'click', (event) =>
      checkbox = $(event.currentTarget)
      card = checkbox.closest ".card"
      @submitFormForColumn(checkbox, card)

    @select.on 'change', (event) =>
      select = $(event.currentTarget)
      card = select.closest ".card"
      @submitFormForColumn(select, card)

    @edit_column.on 'click', (event) =>
      link = $(event.currentTarget)
      card = link.closest ".card"
      hidden_field = card.find("input[type='hidden']")
      @submitFormForColumn(hidden_field, card)

  submitFormForColumn: (clickedElement, card) ->
    form_data = {}
    form_data[clickedElement.attr('name')] = clickedElement.val()
    $.ajax
      url: @form.attr('action')
      type: 'PATCH'
      dataType: 'script'
      data: form_data

  updatePage: (params) ->
    # Replace the header stats
    $(FieldsMapper.HEADER_STATS_AREA_SELECTOR).replaceWith(params.headerStatsContent)

    # Replace the errors block
    $(FieldsMapper.ERROR_AREA_SELECTOR).html(params.importerErrorsContent)

    # update the card content and classes
    cardHeader = $(params.cardHeaderSelector)
    card = cardHeader.closest(".card")
    cardHeader.replaceWith(params.cardHeaderContent)
    $(card).attr('class', params.cardClass)
    $(card).attr("data-mapped", params.columnMapped)

    # Reset events on the card
    @setEventsOnImportColumn(params.columnSelector)

    # Reset the highlight toggle to it's appropriate state
    @setHighlightsBasedOnStatus()

    # if there are any duplicate columns, let's hook them up
    @setDuplicateMappedButtonListeners()
