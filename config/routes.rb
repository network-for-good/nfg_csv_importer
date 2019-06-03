NfgCsvImporter::Engine.routes.draw do
  resources :imports, path: '' do
    resource :review do
      get :show
    end
    resource :process, only: :create
    get :template, on: :collection
  end

  get 'reviews/preview', to: 'reviews#preview', as: 'preview'

  resource :pre_processes do
    get :import_type, as: 'import_type'
    post :get_started, as: 'get_started'
    get :new
    # for hacking around imports#create for preview purposes
    post :create, as: 'create'
  end

  namespace :onboarding do
    resources :import_data, controller: :import_data
  end
end
