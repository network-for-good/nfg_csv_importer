# TODO: Look into inheritance so that the variables that represent the structure of the importer page
# eg: @checkboxSelector can be passed across differnet coffeescript files so we have
# one centralized source of those variables.

# Purpose: Deliver the interaction design for notifying the user
# that the data adjustments are being automatically saved

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
    @alertGrowlElement = $(".alert-growl")

    # Autosave Message Details
    @columnIndexOutputClass = "additionalInfo"
    @columnIndexOutputSelector = ".additionalInfo"
    @saveMessage = "Auto-saving adjustments to column "
    @zIndexVal = 0

    $(@alertGrowlSelector).css("z-index", @zIndexVal)

    # Autosaved HTML Output
    @autosaveHTML = """
                    <div class='alert alert-success #{@alertGrowlClass}' style='z-index:#{@zIndexVal}' role='alert'>
                      #{@saveMessage} <span class='#{@columnIndexOutputClass}'></span>
                      <i class="fa fa-spinner fa-pulse fa-3x fa-fw"></i>
                    </div>
                   """

    # Collect the two interactions that start the process:
    # On click of a checkbox, launch autosave notification
    @checkboxes.on 'click', (event) =>
      checkbox = $(event.currentTarget)

      # Start the process and initialize the auto save animations
      @initAutoSave(checkbox)


    # On change of a select menu, launch autosave notification
    @selects.on 'change', (event) =>
      select = $(event.currentTarget)

      # Start the process and initialize the auto save animations
      @initAutoSave(select)


  # Auto Save animation initializer
  initAutoSave: (clickedElement) ->
    # Update the z-index value so growls appear on top of each other
    @zIndexVal += 1

    # Apply the updated z-index value to the auto save growl
    $(@alertGrowlSelector).css("z-index", @zIndexVal)

    # Remove focus from the element
    clickedElement.blur()

    # Kickoff the auto save growl
    @displayAutoSave(clickedElement)


  # Generate the auto save HTML
  displayAutoSave: (clickedElement) ->

    # Generate the autosave message
    $(@autosaveHTML).appendTo @selfImporterContainer
    $(@alertGrowlSelector).css("z-index", @zIndexVal)

    # Kick off the auto save animation
    @animateAutoSave()


  # Make the magic happen :)
  animateAutoSave: ->
    # Convenience variables
    animationEnd = "webkitAnimationEnd oAnimationEnd msAnimationEnd animationend"
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


$(document).on 'turbolinks:load', ->
  el = $(".col-importer")
  return unless el.length > 0
  inst = new NfgCsvImporter.AutoSaveNotification el
