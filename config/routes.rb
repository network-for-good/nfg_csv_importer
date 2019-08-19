NfgCsvImporter::Engine.routes.draw do
  default_url_options :host => "localhost"

  resources :imports, path: '' do
    resource :review do
      get :show
    end
    resource :process, only: :create
    get :template, on: :collection
    get :reset_onboarder_session, on: :collection
  end

  namespace :onboarding do
    resources :import_data, controller: :import_data
  end
  delete 'attachments/:id', to: 'attachments#destroy', as: :delete_attachment
end
