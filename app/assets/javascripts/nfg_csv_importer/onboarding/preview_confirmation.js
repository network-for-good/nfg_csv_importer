function retrieve_statistics(import_id, url) {
  var numTimes = 0;
  $.ajax({
    url: url || "/imports/" + import_id + "/statistics",
    success: function(data) {
      document.location.reload()
    },
    error: function(data) {
      numTimes += 1;
      if(numTimes < 30) { setTimeout( function(){ retrieve_statistics(import_id) }, 3000) }
    }
  })
}
