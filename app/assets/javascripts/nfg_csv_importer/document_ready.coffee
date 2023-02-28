window.NfgCsvImporter = {}

if $("head [data-turbolinks-track='reload']").length > 0
  window.NfgCsvImporter.readyOrTurboLinksLoad = "turbolinks:load"
else if $("head [data-turbo-track='reload']").length > 0
  window.NfgCsvImporter.readyOrTurboLinksLoad = "turbo:load"
else
  window.NfgCsvImporter.readyOrTurboLinksLoad = "ready"
