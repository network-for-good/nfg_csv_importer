# TODO: Look into inheritance so that the variables that represent the structure of the importer page
# eg: @checkboxSelector can be passed across differnet coffeescript files so we have
# one centralized source of those variables.

class NfgCsvImporter.AutoSaveNotification
  constructor: (@el) ->

    # Page Component Library
    @selfImporterContainer = $("#self_importer")
    @checkboxSelector = "input[type='checkbox']"
    @columnSelector = ".col-importer"
    @checkboxes = @el.find @checkboxSelector
    @selects = @el.find "select"

    # Growl Components
    @alertGrowlClass = "alert-growl"
    @alertGrowlSelector = ".alert-growl"

    # Autosave Message Details
    @columnIndexOutputClass = "additionalInfo"
    @columnIndexOutputSelector = ".additionalInfo"
    @saveMessage = "Auto-saving adjustments to column "
    @zIndexVal = 0

    # Autosaved HTML Output
    @autosaveHTML = """
                    <div class='alert alert-success #{@alertGrowlClass}' style='z-index:#{@zIndexVal}' role='alert'>
                      #{@saveMessage} <span class='#{@columnIndexOutputClass}'></span>
                      <i class="fa fa-spinner fa-pulse fa-3x fa-fw"></i>
                    </div>
                   """

    # Actions
    # On click of a checkbox, launch autosave notification
    @checkboxes.on 'click', (event) =>
      checkbox = $(event.target)
      @displayAutoSave(checkbox)

    # On change of a select menu, launch autosave notification
    @selects.on 'change', (event) =>
      select = $(event.currentTarget)
      @displayAutoSave(select)

  # Display Autosave
  displayAutoSave: (clickedElement) ->
    @zIndexVal = @zIndexVal + 1
    console.log @zIndexVal
    # Determine which column has the interaction
    column = clickedElement.closest(@columnSelector)

    # Grab the column index letter so we can display it in the auto save notification
    columnIndex = column.find(".col-index").data("column")

    # Generate the autosave message
    $(@autosaveHTML).appendTo @selfImporterContainer

    # Inject the column index additional content
    $(@columnIndexOutputSelector).text columnIndex

    # Animation time!
    @animateAutoSave()

  # Make the magic happen :)
  animateAutoSave: =>

    # Convenience variables
    animationEnd = "animationend webkitAnimationEnd oAnimationEnd msAnimationEnd"
    growlStep1 = "growl-step1"
    growlStep2 = "growl-step2"
    growlStep3 = "growl-step3"

    # Step 1: Introduce Growl
    $(@alertGrowlSelector).addClass(growlStep1).on animationEnd, ->

      # Step 2: Announce Autosave
      $(@).addClass(growlStep2).on animationEnd, ->

        # Step 3: End autosave notification
        $(@).addClass(growlStep3).on animationEnd, ->

          # Step 4: remove the HTML
          $(@).remove()
          return false


$(document).on 'ready', ->
  el = $(".col-importer")
  return unless el.length > 0
  inst = new NfgCsvImporter.AutoSaveNotification el
