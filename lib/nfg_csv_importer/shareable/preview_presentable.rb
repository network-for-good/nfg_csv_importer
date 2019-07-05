module NfgCsvImporter
  module PreviewPresentable
    def humanized_card_body_icon(keyword)
      super(keyword, extant?(keyword))
    end

    private

    def extant?(keyword)
      respond_to?(keyword.to_sym, :include_private) ? send(keyword).present? : false
    end
  end
end
