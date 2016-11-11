#= require spec_helper
#= require nfg_csv_importer/fields_mapper

describe "NfgCsvImporter::HighlightUnmappedColumns.toggleHighlights", ->

  beforeEach ->
    $('body').html(JST['templates/fields_mapping_base']({ highlight_status: 'enabled' }))
    @highlighter = new NfgCsvImporter.FieldsMapper

  it "changes the data-unmapped-highlight value from enabled to disabled", ->
    # seems we have to define highlighter here. If defined in the before
    # block, it isn't available here
    # if defined outsite of the this and the before block, it is not scoped
    # to the iframe, so doesn't affect the dom within the iframe
    expect($('.nfg-csv-importer')).to.have.attr('data-unmapped-highlight', 'enabled')
    @highlighter.toggleHighlights()
    expect($('.nfg-csv-importer')).to.have.attr('data-unmapped-highlight', 'disabled')
