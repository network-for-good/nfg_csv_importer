#= require activestorage
#= require nfg_csv_importer/onboarding/dropzone

class NfgCsvImporter.DragdropUpload
  constructor: (@el) ->
    root = @el
    fileInputField = root.querySelector('input[type="file"]')
    url = fileInputField.dataset.directUploadUrl
    name = fileInputField.name

    fileInputField.remove()

    myDropzone = new Dropzone(root.querySelector('.dropzone-target'), {
      url: url,
      autoQueue: false,
      previewTemplate: "
        <div class='dz-preview row align-items-center'>
          <div class='col-2'>
            <img data-dz-thumbnail class='img img-fluid' />
          </div>
          <div class='col-10'>
            <p class='mb-0'>
              <span data-dz-name></span>
              <small class='text-muted mr-2'>
                (<span data-dz-size></span>)
              </small>
              <span data-dz-remove class='text-danger'>remove file</span>
            </p>
            <div class='media align-items-center mt-1'>
              <div class='media-body'>
                <div class='progress progress-sm'>
                  <div data-dz-uploadprogress class='progress-bar' style='width:0%;'></div>
                </div>
              </div>
              <div class='ml-2'>
                <div class='dz-success-mark'><i class='fa fa-fw fa-check text-success'></i></div>
                <div class='dz-error-mark'><i class='fa fa-fw fa-times text-danger'></i></div>
              </div>
            </div>
            <p data-dz-errormessage class='mb-0 text-danger font-weight-bold'></p>
          </div>
        </div>",
      drop: (event) =>
        event.preventDefault()
        files = event.dataTransfer.files
        Array.from(files).forEach (file) =>
          @directUploadFile(file, url, name)
    })

    # When removing files, it does not appear to remove
    # the started and drag-hover classes.
    myDropzone.on 'reset', =>
      @resetUI $(myDropzone.element)

  resetUI: (dropzoneEl) ->
    dropzoneEl.removeClass 'dz-started dz-drag-hover'

  directUploadFile: (file, url, name) =>
    upload = new ActiveStorage.DirectUpload(file, url, this);

    upload.create (error, blob) =>
      if (error)
        # Handle the error
      else
        hiddenField = document.createElement('input')
        hiddenField.setAttribute("type", "hidden")
        hiddenField.setAttribute("value", blob.signed_id)
        hiddenField.name = name
        $('form')[0].appendChild(hiddenField)

$ ->
  el = $("#pre_processing_files_upload")
  return unless el.length > 0
  inst = new NfgCsvImporter.DragdropUpload el[0]
