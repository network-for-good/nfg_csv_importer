function retrieve_statistics(url) {
  var numTimes = 0;
  $.ajax({
    url: url,
    success: function(data) {
      document.location.reload()
    },
    error: function(data) {
      numTimes += 1;
      if(numTimes < 30) { setTimeout(function() { retrieve_statistics(url) }, 3000) }
    }
  })
}
