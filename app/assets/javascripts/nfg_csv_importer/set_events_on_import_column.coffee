class NfgCsvImporter.SetEventsOnImportColumn
  constructor: (el) ->
    @column = $(el)
    @checkbox = @column.find "input[type='checkbox']"
    @select = @column.find "select"
    @edit_column =  @column.find "a[data-edit-column='true']"
    @form = $("form#fields_mapping")

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
