// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//


//= require jquery
// jquery_ujs
// mousetrap
// keybindings
// turbolinks
// handlebars-v4.0.5
// jquery.ui.datepicker
// jquery.ui.sortable
// readmore.min
// _tree ../../../vendor/assets/javascripts/redactor
// Chart.min
// twitter/typeahead
// select2.min
// blockUI.min
// moment
// bootstrap-datetimepicker
//= require tether.min
// accountingjs
// jquery.sticky
// _directory ../../../vendor/assets/javascripts/linkify

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
