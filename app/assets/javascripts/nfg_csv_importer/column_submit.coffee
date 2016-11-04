class NfgCsvImporter.ImporterColumn
  constructor: (@el) ->
    @checkboxes = @el.find "input[type='checkbox']"
    @selects = @el.find "select"
    @form = $("form#fields_mapping")
    @edit_columns = $("a[data-edit-column='true']")

    @checkboxes.on 'click', (event) =>
      checkbox = $(event.currentTarget)
      card = checkbox.closest ".card"
      @submitFormForColumn(checkbox, card)

    @selects.on 'change', (event) =>
      select = $(event.currentTarget)
      card = select.closest ".card"
      @submitFormForColumn(select, card)

    @edit_columns.on 'click', (event) =>
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

$(document).on 'turbolinks:load', ->
  el = $(".col-importer")
  return unless el.length > 0
  inst = new NfgCsvImporter.ImporterColumn el
