module NfgCsvImporter
  class Engine < ::Rails::Engine
    isolate_namespace NfgCsvImporter

    initializer 'nfg_csv_importer.assets.precompile' do |app|
      app.config.assets.precompile << "#{Engine.root.join('app', 'assets', 'config')}/nfg_csv_importer_manifest.js"
    end
  end
end
