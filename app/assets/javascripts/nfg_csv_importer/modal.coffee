class NfgCsvImporter.ImporterGemModal
  constructor: ->
    @modals = $("[data-modal-identifier='importer_gem_modal']")
    @importerGemModalToggles = $("[data-toggle='modal'][data-importer-gem-modal='true']")
    @targetModals = $("[data-toggle='modal'][data-importer-gem-modal='true']").data "target"
    @modalCloseButtons = $("[data-modal-identifier='importer_gem_modal'] [data-dismiss='modal']")
    @placeholder = $("<span data-describe='importer_gem_modal_placeholder' data-modal-placeholder='#{@targetModals}'></span>")

    console.log "the amount of kickoff buttons is " + @importerGemModalToggles.length
    console.log "the targetModal is " + @targetModals

    @importerGemModalToggles.on 'click', (event) =>
      console.log "within modal toggle click"
      console.log "prev modal is " + $(@targetModals).prev().attr "class"

      event.stopPropagation()
      console.log "stopped propogation"



      console.log "placeholder count after storing it as a variable is " + $("#importer_gem_modal_placeholder").length

      @placeholder.insertAfter $(@targetModals).prev()
      console.log "appended placeholder"
      console.log "placeholder count after placing it is " + $("#importer_gem_modal_placeholder").length

      detachedModal = $(@targetModals).detach()
      console.log "target modal was detached and the count of detachedModal is " + detachedModal.length

      detachedModal.appendTo "body"
      console.log "detachedModal appended to body and the count of detachedModal is " + detachedModal.length

      $(@targetModals).on 'show.bs.modal', ->
        console.log "within show.bs.modal"
        setTimeout (->

          detachedModal.wrap "<span class='importer-gem modal-interstitial-wrapper' data-importer-gem-modal-status='present'></span>"
          console.log "wrapped modal in span"
          $(".modal-backdrop").addClass "importer-gem modal-interstitial-wrapper"
          console.log "added class to backdrop"
        ), 1

      $(@targetModals).modal()

      console.log "modal fired"



    @modals.on "hide.bs.modal", (event) =>
      console.log "within hide"
      @returningModal = @modals.detach()
      console.log "saved detached modal within hide"

    @modals.on "hidden.bs.modal", (event) =>
      console.log "within hidden"
      @placeholder.replaceWith @returningModal
      console.log "added modal back via replacedwith"

      console.log "about to remove status='present' wrapper, count is " + $("[data-importer-gem-modal-status='present']").length
      $("[data-importer-gem-modal-status='present']").remove()
      console.log "removed status='present' wrapper, count is " + $("[data-importer-gem-modal-status='present']").length



$(document).on NfgCsvImporter.readyOrTurboLinksLoad, ->

  importerGemModal = $("[data-modal-identifier='importer_gem_modal']")
  return unless importerGemModal.length > 0
  inst = new NfgCsvImporter.ImporterGemModal importerGemModal
