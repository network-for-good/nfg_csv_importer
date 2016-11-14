#= require spec_helper
#= require nfg_csv_importer/fields_mapper

describe "NfgCsvImporter::FieldsMapper", ->
  before ->
    @fieldsMapperClass = NfgCsvImporter.FieldsMapper
  describe "#toggleHighlights", ->
    beforeEach ->
      $('body').html(JST['templates/fields_mapping_base']({ highlight_status: 'enabled' }))
      @fieldsMapper = new NfgCsvImporter.FieldsMapper

    it "changes the data-unmapped-highlight value from enabled to disabled", ->
      expect($('.nfg-csv-importer')).to.have.attr('data-unmapped-highlight', 'enabled')
      @fieldsMapper.toggleHighlights()
      expect($('.nfg-csv-importer')).to.have.attr('data-unmapped-highlight', 'disabled')

    it "should call the setHighLightsBasedOnStatus function", ->
      spy = chai.spy.on(@fieldsMapper, "setHighlightsBasedOnStatus")
      @fieldsMapper.toggleHighlights()
      expect(spy).to.have.been.called.once


  describe "#setHighlightsBasedOnStatus when highlight status is enabled", ->
    beforeEach ->
      $('body').html(JST['templates/fields_mapping_base']({ highlight_status: 'enabled' }))
      $('form#fields_mapping div.row').html(JST['templates/unmapped_field_column']({ field_name: "Donor First Name", field_id: "donor_first_name", highlight_class: '' }))
      @card = $(".card")
      @fieldsMapper = new NfgCsvImporter.FieldsMapper

    it "should add the card-highlight class to the unmapped column ", ->
      expect(@card).not.to.have.class(@fieldsMapperClass.CARD_HIGHLIGHT_CLASS)
      @fieldsMapper.setHighlightsBasedOnStatus()
      expect(@card).to.have.class(@fieldsMapperClass.CARD_HIGHLIGHT_CLASS)

  describe "#setHighlightsBasedOnStatus when highlight status is disabled", ->
    beforeEach ->
      $('body').html(JST['templates/fields_mapping_base']({ highlight_status: 'disabled' }))

    describe "#and the column was not previously highlighted", ->
      beforeEach ->
        $('form#fields_mapping div.row').html(JST['templates/unmapped_field_column']({ field_name: "Donor First Name", field_id: "donor_first_name", highlight_class: ''}))
        @card = $(".card")
        @fieldsMapper = new NfgCsvImporter.FieldsMapper

      it "should NOT add the card-highlight class to the unmapped column ", ->
        expect(@card).not.to.have.class(@fieldsMapperClass.CARD_HIGHLIGHT_CLASS)
        @fieldsMapper.setHighlightsBasedOnStatus()
        expect(@card).not.to.have.class(@fieldsMapperClass.CARD_HIGHLIGHT_CLASS)

    describe "#and the column was previously highlighted", ->
      beforeEach ->
        $('form#fields_mapping div.row').html(JST['templates/unmapped_field_column']({ field_name: "Donor First Name", field_id: "donor_first_name", highlight_class: 'card-highlight'}))
        @card = $(".card")
        @fieldsMapper = new NfgCsvImporter.FieldsMapper

      it "should remove the card-highlight class to the unmapped column ", ->
        expect(@card).to.have.class(@fieldsMapperClass.CARD_HIGHLIGHT_CLASS)
        @fieldsMapper.setHighlightsBasedOnStatus()
        expect(@card).not.to.have.class(@fieldsMapperClass.CARD_HIGHLIGHT_CLASS)


