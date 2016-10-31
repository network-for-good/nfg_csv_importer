NfgCsvImporter::Engine.routes.draw do
  resources :imports, path: '' do
    resource :review
  end
end
