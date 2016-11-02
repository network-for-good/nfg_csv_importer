$(document).on 'turbolinks:load', ->
  $('#importer_header_bar').sticky
    widthFromWrapper: false
    topSpacing: 48
    className: 'header-is-stuck'
    wrapperClassName: 'importer-header-bar-wrapper'
    zIndex: 99
  return
