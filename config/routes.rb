NfgCsvImporter::Engine.routes.draw do
  resources :imports, path: '' do
    resource :review, only: :show
    resource :process, only: :create
    get :template, on: :collection
  end


  get 'pre_processes/get_started', to: 'pre_processes#get_started', as: 'pre_processes_get_started'

end
