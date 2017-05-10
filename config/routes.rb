NfgCsvImporter::Engine.routes.draw do
  resources :imports, path: '' do
    resource :review, only: :show
    resource :process, only: :create
    get :template, on: :collection
  end
end
