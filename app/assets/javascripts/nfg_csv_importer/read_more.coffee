class NfgCsvImporter.ReadMore
  constructor: (@el) ->
    $(@el).readmore
      maxHeight: $(@el).data('max-height') || 100
      moreLink: '<a href="javascript:;" class="d-block mt-2">View All<i class="fa fa-caret-down ml-1"></i></a>'
      lessLink: '<a href="javascript:;" class="d-block mt-2">Hide<i class="fa fa-caret-up ml-1"></i></a>'


$ ->
  expandables = $('.expandable')
  return unless expandables.length > 0
  expandables.each ->
    inst = new NfgCsvImporter.ReadMore $(@)
