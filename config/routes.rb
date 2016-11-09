NfgCsvImporter::Engine.routes.draw do
  resources :imports, path: '' do
    resource :review, only: :show
    resource :process, only: :create
  end
end
