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

  describe "#updatePage", ->
    beforeEach ->
      @fieldName = "Donor First Name"
      @fieldId = "donor_first_name"
      $('body').html(JST['templates/fields_mapping_base']({ highlight_status: 'enabled' }))
      $('form#fields_mapping div.row').html(JST['templates/mapped_field_column']({ field_name: @fieldName, field_id: @fieldId }))

      @fieldsMapper = new NfgCsvImporter.FieldsMapper
      @params = {
                  headerStatsContent: "<div id='importer_header_stats'>__header_stats__</div>",
                  importerErrorsContent: "__importer_errors__",
                  cardHeaderSelector: "#card_header_#{ @fieldId }",
                  cardHeaderContent: "<div id='card_header_#{ @fieldId }'>__card_header_content__</div>"
                  cardClass: "card card-unmapped",
                  columnMapped: "false",
                  columnSelector: ".col-importer[data-column-name='#{ @fieldName }']"
                }
      @errorArea = $(@fieldsMapperClass.ERROR_AREA_SELECTOR)

    it "should replace the header stats with the content in headerStatsContent", ->
      $(@fieldsMapperClass.HEADER_STATS_AREA_SELECTOR).should.not.have.text("__header_stats__")
      @fieldsMapper.updatePage(@params)
      $(@fieldsMapperClass.HEADER_STATS_AREA_SELECTOR).should.have.text("__header_stats__")

    it "should replace the content of the error area with the importerErrorsContent", ->
      $(@fieldsMapperClass.ERROR_AREA_SELECTOR).should.not.have.text("__importer_errors__")
      @fieldsMapper.updatePage(@params)
      $(@fieldsMapperClass.ERROR_AREA_SELECTOR).should.have.text("__importer_errors__")

    it "should replace the card header content with the cardHeaderContent", ->
      $(@params.cardHeaderSelector).should.not.have.text("__card_header_content__")
      @fieldsMapper.updatePage(@params)
      $(@params.cardHeaderSelector).should.have.text("__card_header_content__")

    it "should update the class of the containing card", ->
      card = $(@params.cardHeaderSelector).closest('.card')
      $(card).should.have.class('card card-mapped')
      @fieldsMapper.updatePage(@params)
      expect($(card)).to.have.class(@params.cardClass)

