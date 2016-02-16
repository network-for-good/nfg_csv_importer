NfgCsvImporter::Engine.routes.draw do
  resources :imports, :only => [:show, :new, :create, :index], path: ''
end
