Rails.application.routes.draw do

  mount NfgCsvImporter::Engine => "/nfg_csv_importer"
  root 'nfg_csv_importer/imports#index'
end
