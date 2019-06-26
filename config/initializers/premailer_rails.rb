if defined?(Rails)

  Premailer::Rails.config.merge!(preserve_styles: true,
                                 remove_ids: false, # IDs are typically for specs and are never styled.
                                 remove_comments: true)
end