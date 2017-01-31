# Detect IE11 and add a unique class to the html element like modernizr

# Note: the only official ie11 "unique" attribute is "msTextCombineHorizontal", however
# Targeting IE11 with a media query for "msTextCombineHorizontal" will also target IE12+
# Thus, there isn't (as of yet) a way to target IE11 only through media queries.

$(document).on 'turbolinks:load', ->
  if bowser.check({msie: "11"}) # check for IE11
    $("html").addClass "no-maxwidth"

