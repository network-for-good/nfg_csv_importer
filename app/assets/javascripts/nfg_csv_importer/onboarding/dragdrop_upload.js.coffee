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
      previewTemplate: '<div class="list-group-item w-100"><div class="row"><div class="col-2"><img data-dz-thumbnail class="img img-fluid" /></div><div class="col-4"><span data-dz-size /></div><div class="col-6"><span data-dz-name></span></div></div><div class="row"><div class="col-12 mt-2"><div class="progress"><div class="progress-bar bg-dark" style="width:0%;" ></div></div></div></div></div>',
      drop: (event) =>
        event.preventDefault()
        files = event.dataTransfer.files
        Array.from(files).forEach (file) =>
          @directUploadFile(file, url, name)
    })

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
