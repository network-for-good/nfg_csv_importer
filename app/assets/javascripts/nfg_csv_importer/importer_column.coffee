class NfgCsvImporter.ImporterColumn
  constructor: (@el) ->


    @checkboxes = @el.find "input[type='checkbox']"
    @selects = @el.find "select"

    @checkboxes.on 'click', (event) =>
      checkbox = $(event.currentTarget)
      card = checkbox.closest ".card"

      @updateColumnAppearance(checkbox, card)
      # Need to submit the form and have it accept an ignore command...

    @selects.on 'change', (event) =>
      select = $(event.currentTarget)
      card = select.closest ".card"

      @updateColumnAppearance(select, card)
      @submitFormForColumn(select, card)


  updateColumnAppearance: (clickedElement, card) ->
    headerName = card.find('.card-header').data "header-name"
    card.find("[data-describe='source-column-header-name']").wrapInner "<s class='text-muted'></s>"



    # if clickedElement.is("input[type='checkbox']")
    #   if clickedElement.attr("name") == "ignore_column_" + headerName && (!$(clickedElement).is(":checked"))
    #     card.toggleClass "card-disabled"



  submitFormForColumn: (clickedElement, card) ->
    form_data = {}
    form_data[clickedElement.attr('name')] = clickedElement.val()
    $.ajax
      url: $(@form).attr('action')
      type: 'PATCH'
      dataType: 'script'
      data: form_data

$(document).on 'turbolinks:load', ->
  el = $(".col-importer")
  return unless el.length > 0
  inst = new NfgCsvImporter.ImporterColumn el
