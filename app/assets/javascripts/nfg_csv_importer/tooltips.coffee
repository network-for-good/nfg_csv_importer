$(document).on NfgCsvImporter.readyOrTurboLinksLoad, ->

  if !('ontouchstart' of window) # Disable tooltips on touch devices
    $('[data-toggle="tooltip"]').tooltip trigger: 'hover', container: 'body'

    # Re-fire and turn on tooltips when a modal fires
    # Allows tooltips to show up on modals that load content async.
    $('.modal').on 'shown.bs.modal', ->
      $(@).find('[data-toggle="tooltip"]').tooltip trigger: 'hover', container: '.modal'

    $('[data-toggle="tooltip"]').on 'click', ->
      $(@).tooltip 'hide'


    $('[data-toggle="tooltip"]').on 'show.bs.tooltip', ->
      setTimeout (->
        $('.tooltip').wrap "<span class='importer-gem' data-tooltip-status='present'></div>"
      ), 1   # Simple timeout removes flicker due to wrapping... 'shown.bs.tooltip' generates a flicker.

    $('[data-toggle="tooltip"]').on 'hidden.bs.tooltip', ->
      # setTimeout (->
      $("[data-tooltip-status='present']").remove()
      # ), 100   # Simple timeout removes flicker due to wrapping... 'shown.bs.tooltip' generates a flicker.


