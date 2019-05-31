module NfgCsvImporter
  class Engine < ::Rails::Engine
    isolate_namespace NfgCsvImporter

    # This allows us to declare folders and assets for precompilation
    # to be consumed by host apps. To update precompilation assets
    # edit: app/assets/config/nfg_csv_importer_manifest.js
    #
    # Utilize sprockets syntax, ex:
    # //= link_tree ../images/nfg_csv_importer
    initializer 'nfg_csv_importer.assets.precompile' do |app|
      app.config.assets.precompile << "#{Engine.root.join('app', 'assets', 'config')}/nfg_csv_importer_manifest.js"
    end
  end
end
