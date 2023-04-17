Rails.application.routes.draw do

  mount NfgCsvImporter::Engine => "/imports"
  root 'nfg_csv_importer/imports#index'
end
