//= require jquery
//= require jquery_ujs
// mousetrap
// keybindings
// turbolinks
// handlebars-v4.0.5
// jquery.ui.datepicker
// jquery.ui.sortable
// readmore.min
// tree ../../../vendor/assets/javascripts/redactor
// Chart.min
// twitter/typeahead
// select2.min
// blockUI.min
// moment
// bootstrap-datetimepicker
//= require tether.min
// accountingjs
// jquery.sticky
// directory ../../../vendor/assets/javascripts/linkify

// Bootstrap4
//= require bootstrap4/bootstrap.min
//= require_self
//= require_directory ./
//= require_tree .

$(document).ready(function() {

  $('#new_import_service').submit(function() {
    $('<div id="overlay"> </div>').appendTo(document.body);
    $("#spinner").show();
  });
  $("#spinner").hide();

});
