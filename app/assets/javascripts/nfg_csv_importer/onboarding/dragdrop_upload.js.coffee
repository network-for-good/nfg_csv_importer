#= require activestorage
#= require nfg_csv_importer/onboarding/dropzone
###
  Location for these uploaded files will be specified in config/storage.yml
  Storage service will be specified in environment file i.e `config.active_storage.service = :local`
###

class NfgCsvImporter.Uploader
  constructor: (file, url, name) ->
    @file = file
    @url  = url
    @name = name
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
        file.previewElement.querySelector('a.dz-remove').dataset.signed_id = blob.signed_id

  directUploadWillStoreFileWithXHR: (request) =>
    request.upload.addEventListener("progress", (event) => @directUploadDidProgress(event))

  directUploadDidProgress: (event) =>
    progressBar = this.file.previewElement.querySelector('.progress .progress-bar')
    progressBar.style.width = "#{event.loaded * 100 / event.total}%"
    progressBar.setAttribute 'aria-valuenow', "#{event.loaded * 100 / event.total}"

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
      clickable: '#dz_file_browser_link',
      dictDuplicateFile: "Duplicate Files Cannot Be Uploaded",
      preventDuplicates: true,
      addRemoveLinks: true,
      acceptedFiles: 'text/csv,application/vnd.ms-excel,application/vnd.openxmlformats-officedocument.spreadsheetml.sheet,.xls',
      previewTemplate: document
                        .querySelector('#tpl')
                        .innerHTML
    })

    # When removing files, it does not appear to remove
    # the started and drag-hover classes.
    myDropzone.on 'reset', =>
      @resetUI $(myDropzone.element)
    myDropzone.on 'addedfile', (file)=>
      new NfgCsvImporter.Uploader(file, url, name)
      file.previewElement.setAttribute 'data-describe', "dz-#{file.name}"
    myDropzone.on 'removedfile', (file)=>
      signed_id = file.previewElement.querySelector('a.dz-remove').dataset.signed_id
      $("input[value='#{signed_id}']").remove()

    myDropzone.on 'error', (file) =>
      successMark = $(file.previewElement).find('.dz-success-mark')

      errorMark = $(file.previewElement).find('.dz-error-mark')

      errorMark.removeClass 'd-none'
      errorMark.show()
      successMark.hide()

    $('#stored_files input[type="hidden"]').each ->
      existingFile = { name: @.dataset.name, size: @.dataset.size, accepted: true }
      myDropzone.options.addedfile.call(myDropzone, existingFile)
      previewElement = existingFile.previewElement
      previewElement.querySelector('a.dz-remove').dataset.signed_id = @.value
      previewElement.querySelector('.progress .progress-bar').style.width = "100%"
      previewElement.querySelector('.progress .progress-bar').setAttribute('aria-valuenow',100)
      myDropzone.files.push(existingFile)

  resetUI: (dropzoneEl) ->
    dropzoneEl.removeClass 'dz-clickable dz-started'

$ ->
  el = $("#pre_processing_files_upload")
  return unless el.length > 0
  inst = new NfgCsvImporter.DragdropUpload el[0]
