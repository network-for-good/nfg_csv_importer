$(document).on 'click', '[data-smooth-scroll-target]', ->
  target = $($(@).data('smooth-scroll-target'))
  $('html').animate({ scrollTop: target.offset().top - 49 }, 600)
