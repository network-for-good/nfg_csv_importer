$(document).on NfgCsvImporter.readyOrTurboLinksLoad, ->

  if !('ontouchstart' of window) # Disable tooltips on touch devices
    $('.importer-gem [data-toggle="tooltip"]').tooltip trigger: 'hover', container: 'body'

    # Re-fire and turn on tooltips when a modal fires
    # Allows tooltips to show up on modals that load content async.
    $('.modal').on 'shown.bs.modal', ->
      $(@).find('.importer-gem [data-toggle="tooltip"]').tooltip trigger: 'hover', container: '.modal'

    $('.importer-gem [data-toggle="tooltip"]').on 'click', ->
      $(@).tooltip 'hide'


    $('.importer-gem [data-toggle="tooltip"]').on 'show.bs.tooltip', ->
      setTimeout (->
        $('.tooltip').wrap "<span class='importer-gem' data-tooltip-status='present'></div>"
      ), 1   # Simple timeout removes flicker due to wrapping... 'shown.bs.tooltip' generates a flicker.

    $('.importer-gem [data-toggle="tooltip"]').on 'hidden.bs.tooltip', ->
      $(".importer-gem [data-tooltip-status='present']").remove()



