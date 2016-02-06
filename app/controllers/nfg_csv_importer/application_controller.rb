module NfgCsvImporter
  class ApplicationController < NfgCsvImporter.inherited_controller.constantize
    def current_user
      User.first
    end
  end
end
