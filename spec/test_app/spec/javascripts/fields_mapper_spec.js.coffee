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
      $('body').append(JST['templates/highlight_switch']())
      $('form#fields_mapping div.row').html(JST['templates/unmapped_field_column']({ field_name: "Donor First Name", field_id: "donor_first_name", highlight_class: '' }))
      @card = $(".card")
      @turnHighlightsOffSwitch = $(@fieldsMapperClass.TURN_HIGHLIGHT_OFF_ID)
      @turnHighlightsOnSwitch = $(@fieldsMapperClass.TURN_HIGHLIGHT_ON_ID)
      @fieldsMapper = new NfgCsvImporter.FieldsMapper

    it "should add the card-highlight class to the unmapped column ", ->
      expect(@card).not.to.have.class(@fieldsMapperClass.CARD_HIGHLIGHT_CLASS)
      @fieldsMapper.setHighlightsBasedOnStatus()
      expect(@card).to.have.class(@fieldsMapperClass.CARD_HIGHLIGHT_CLASS)

    it "should hide the turnHighlightsOnSwitch", ->
      expect(@turnHighlightsOnSwitch).to.be.visible
      @fieldsMapper.setHighlightsBasedOnStatus()
      expect(@turnHighlightsOnSwitch).to.be.hidden

    it "should make visible the turnHighlightsOffSwitch", ->
      expect(@turnHighlightsOffSwitch).to.be.hidden
      @fieldsMapper.setHighlightsBasedOnStatus()
      expect(@turnHighlightsOffSwitch).to.be.visible

  describe "#setHighlightsBasedOnStatus when highlight status is disabled", ->
    beforeEach ->
      $('body').html(JST['templates/fields_mapping_base']({ highlight_status: 'disabled' }))
      $('body').append(JST['templates/highlight_switch']())
      @turnHighlightsOffSwitch = $(@fieldsMapperClass.TURN_HIGHLIGHT_OFF_ID)
      @turnHighlightsOnSwitch = $(@fieldsMapperClass.TURN_HIGHLIGHT_ON_ID)
      @fieldsMapper = new NfgCsvImporter.FieldsMapper

    describe "#and the column was not previously highlighted", ->
      beforeEach ->
        $('form#fields_mapping div.row').html(JST['templates/unmapped_field_column']({ field_name: "Donor First Name", field_id: "donor_first_name", highlight_class: ''}))
        @card = $(".card")

      it "should NOT add the card-highlight class to the unmapped column ", ->
        expect(@card).not.to.have.class(@fieldsMapperClass.CARD_HIGHLIGHT_CLASS)
        @fieldsMapper.setHighlightsBasedOnStatus()
        expect(@card).not.to.have.class(@fieldsMapperClass.CARD_HIGHLIGHT_CLASS)

    it "should leave the turnHighlightsOnSwitch visible", ->
      expect(@turnHighlightsOnSwitch).to.be.visible
      @fieldsMapper.setHighlightsBasedOnStatus()
      expect(@turnHighlightsOnSwitch).to.be.visible

    it "should leave the turnHighlightsOffSwitch hidden", ->
      expect(@turnHighlightsOffSwitch).to.be.hidden
      @fieldsMapper.setHighlightsBasedOnStatus()
      expect(@turnHighlightsOffSwitch).to.be.hidden

    describe "#and the column was previously highlighted", ->
      beforeEach ->
        $('form#fields_mapping div.row').html(JST['templates/unmapped_field_column']({ field_name: "Donor First Name", field_id: "donor_first_name", highlight_class: 'card-highlight'}))
        @card = $(".card")
        @fieldsMapper = new NfgCsvImporter.FieldsMapper

      it "should remove the card-highlight class to the unmapped column ", ->
        expect(@card).to.have.class(@fieldsMapperClass.CARD_HIGHLIGHT_CLASS)
        @fieldsMapper.setHighlightsBasedOnStatus()
        expect(@card).not.to.have.class(@fieldsMapperClass.CARD_HIGHLIGHT_CLASS)


