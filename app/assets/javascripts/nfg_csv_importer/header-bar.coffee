$(document).on 'turbolinks:load', ->

  $(window).scroll ->
    scroll = $(window).scrollTop()
    if scroll > 0
      $('#importer_header_bar').addClass "header-is-stuck"
    else
      $('#importer_header_bar').removeClass "header-is-stuck"
    return
  return


