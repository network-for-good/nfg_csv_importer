class NfgCsvImporter.ImporterGemModal
  constructor: (@importerGemModal)->

    # Modal Pieces
    @impoerterGemModalToggerIdentifier = "[data-importer-gem-modal-toggle='true']"
    @importerGemModalIdentifier = "[data-modal-identifier='importer_gem_modal']"
    @importerGemNamespace = "importer-gem"
    @importerGemInterstitialWrapper = "modal-interstitial-wrapper"
    @placeholderDataDescribe = "data-describe='importer-gem-modal-placeholder'"
    # @placeholderDataAttributes = "data-describe='importer_gem_modal_placeholder' data-modal-placeholder='#{@targetModals}'"

    # Modal Components
    @importerGemModalToggles = $("[data-toggle='modal']#{@impoerterGemModalToggerIdentifier}")
    @importerGemModalWrapperHTML = "<span class='#{@importerGemNamespace} #{@importerGemInterstitialWrapper}' data-importer-gem-modal-status='present'></span>"

    # Modal Identifiers
    # @targetModals = $("[data-toggle='modal']#{@impoerterGemModalToggerIdentifier}").data "target"
    @modalCloseButtons = $("#{@importerGemModalIdentifier} [data-dismiss='modal']")

    # Modal Supporters
    @placeholder = $("<span #{@placeholderDataDescribe}></span>")


    @importerGemModalToggles.on "click", (event) =>
      event.stopPropagation() # short circuit bootstrap's modal JS
      @launchModal $($(event.target).data "target")

    @importerGemModal.on "hidden.bs.modal", (event) =>
      returningModal = @importerGemModal.detach()
      @placeholder.replaceWith returningModal
      $("[data-importer-gem-modal-status='present']").remove()


  launchModal: (targetModal) ->
    # do we run a function here to do the interstitial checking or... just do the if statements here?
    @placeholder.insertAfter targetModal.prev()

    targetModal.detach().appendTo "body"

    targetModal.on "show.bs.modal", (event) =>
      setTimeout (=>
        targetModal.wrap @importerGemModalWrapperHTML
        $(".modal-backdrop").addClass "importer-gem modal-interstitial-wrapper"
      ), 1

    targetModal.modal()




$(document).on NfgCsvImporter.readyOrTurboLinksLoad, ->

  importerGemModal = $("[data-modal-identifier='importer_gem_modal']")
  return unless importerGemModal.length > 0
  inst = new NfgCsvImporter.ImporterGemModal importerGemModal
