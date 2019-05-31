NfgCsvImporter::Engine.routes.draw do
  resources :imports, path: '' do
    resource :review, only: :show
    resource :process, only: :create
    get :template, on: :collection
  end

  resource :pre_processes do
    post :get_started, as: 'get_started'
    get :import_type, as: 'import_type'
    get :new
  end
end
