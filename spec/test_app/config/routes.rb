Rails.application.routes.draw do

  mount NfgCsvImporter::Engine => "/nfg_csv_importer"
end
