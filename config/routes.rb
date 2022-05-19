NfgCsvImporter::Engine.routes.draw do
  resources :imports, path: '' do
    resource :review do
      get :show
    end

    resource :process, only: :create

    collection do
      get :template
      get :reset_onboarder_session
    end

    member do
      get :statistics
      post :download_attachments
    end
  end

  namespace :onboarding do
    resources :import_data, controller: :import_data
  end

  delete 'attachments/:id', to: 'attachments#destroy', as: :delete_attachment
end
