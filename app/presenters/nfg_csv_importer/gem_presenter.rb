module NfgCsvImporter
  class GemPresenter < SimpleDelegator
    attr_accessor :model, :view, :options

    def initialize(model, view = ActionController::Base.new.view_context, options = {})
      @model, @view, @options = model, view, options
      @options ||= {}
      super(@model)
    end

    def h
      view
    end
  end
end