NfgCsvImporter::Engine.routes.draw do
  resources :imports, path: '' do
    resource :review do
      get :show
    end
    resource :process, only: :create
    get :template, on: :collection
    get :reset_onboarder_session, on: :collection
    post :download_attachments, to: "imports#download_attachments", as: :download_attachments
  end

  namespace :onboarding do
    resources :import_data, controller: :import_data
  end
  delete 'attachments/:id', to: 'attachments#destroy', as: :delete_attachment
end
