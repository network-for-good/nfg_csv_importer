class NfgCsvImporter.ReadMore
  constructor: (@el) ->
    $(@el).readmore
      maxHeight: $(@el).data('max-height') || 100
      moreLink: '<a href="javascript:;" class="text-blue display-block text-xs-center"><i class="fa fa-chevron-down"></i> <strong>See All</strong></a>'
      lessLink: '<a href="javascript:;" class="text-blue display-block text-xs-center"><i class="fa fa-chevron-up"></i> <strong>Hide</strong></a>'


$ ->
  expandables = $('.expandable')
  return unless expandables.length > 0
  expandables.each ->
    inst = new NfgCsvImporter.ReadMore $(@)
