class NfgCsvImporter.ImporterGemModal
  constructor: (@importerGemModal)->
    @importerGemCssNamespace = "importer-gem"
    @interstitialModalClass = "modal-interstitial"
    @importerGemInterstitialWrapperClass = "modal-interstitial-wrapper"
    @importerGemModalToggles = $("[data-importer-gem-modal-toggle='true']")
    @modalIsPresentFlag = "data-importer-gem-modal-status='present'"
    @placeholderSpan = $("<span data-describe='importer-gem-modal-placeholder'></span>")

    @importerGemModalToggles.on "click", (event) =>
      event.stopPropagation() # short circuit bootstrap's modal JS
      @launchModal $($(event.target).data "target")

    @importerGemModal.on "hidden.bs.modal", =>
      @removeModal()


  launchModal: (targetModal) ->
    @determineNamespaceClasses targetModal
    @positionModalOnDocument targetModal
    targetModal.modal()

  determineNamespaceClasses: (targetModal) ->
    @modalNamespaceClasses = @importerGemCssNamespace

    if targetModal.hasClass @interstitialModalClass
      @modalNamespaceClasses += " #{@importerGemInterstitialWrapperClass}"

    @modalWrapper = "<span class='#{@modalNamespaceClasses}' #{@modalIsPresentFlag}></span>"

  positionModalOnDocument: (targetModal) ->
    @placeholderSpan.insertAfter targetModal.prev()
    targetModal.detach().appendTo "body"

    targetModal.on "show.bs.modal", (event) =>
      setTimeout (=>
        targetModal.wrap @modalWrapper
        $(".modal-backdrop").addClass @modalNamespaceClasses
      ), 1

  removeModal: ->
    returningModal = @importerGemModal.detach()
    @placeholderSpan.replaceWith returningModal
    $("[#{@modalIsPresentFlag}]").remove()


$(document).on NfgCsvImporter.readyOrTurboLinksLoad, ->

  importerGemModal = $("[data-modal-identifier='importer_gem_modal']")
  return unless importerGemModal.length > 0
  inst = new NfgCsvImporter.ImporterGemModal importerGemModal
