Rails.application.routes.draw do
  default_url_options :host => "localhost"
  mount NfgCsvImporter::Engine => "/nfg_csv_importer"
  root 'nfg_csv_importer/imports#index'
end
