function retrieve_statistics(import_id) {
  var numTimes = 0;
  $.ajax({
    url: "/imports/" + import_id + "/statistics",
    success: function(data) {
      document.location.reload()
    },
    error: function(data) {
      numTimes += 1;
      if(numTimes < 20) { setTimeout( function(){ retrieve_statistics(import_id) }, 3000) }
    }
  })
}
