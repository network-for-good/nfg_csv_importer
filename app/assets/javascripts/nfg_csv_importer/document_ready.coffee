window.NfgCsvImporter = {}

if $("head [data-turbolinks-track='reload']").length > 0
  window.NfgCsvImporter.readyOrTurboLinksLoad = "turbolinks:load"
else
  window.NfgCsvImporter.readyOrTurboLinksLoad = "ready"