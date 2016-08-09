NfgCsvImporter::Engine.routes.draw do
  resources :imports, :only => [:show, :new, :create, :index, :destroy], path: ''
end
