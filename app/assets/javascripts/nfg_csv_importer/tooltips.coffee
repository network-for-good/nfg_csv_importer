$(document).on 'turbolinks:load', ->

  if !('ontouchstart' of window) # Disable tooltips on touch devices
    $('[data-toggle="tooltip"]').tooltip trigger: 'hover', container: 'body'

    # Re-fire and turn on tooltips when a modal fires
    # Allows tooltips to show up on modals that load content async.
    $('.modal').on 'shown.bs.modal', ->
      $(@).find('[data-toggle="tooltip"]').tooltip trigger: 'hover', container: '.modal'

    $('[data-toggle="tooltip"]').on 'click', ->
      $(@).tooltip 'hide'
