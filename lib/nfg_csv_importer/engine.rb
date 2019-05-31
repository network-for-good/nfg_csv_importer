module NfgCsvImporter
  class Engine < ::Rails::Engine
    isolate_namespace NfgCsvImporter

    # This allows us to declare folders and assets for precompilation.
    # This means showing assets on the host app's views like
    # images, or leveraging custom fonts from this gem's assets folder
    #
    # to be consumed by host apps. To update precompilation assets,
    # edit the manifest js file found here:
    # app/assets/config/nfg_csv_importer_manifest.js
    #
    # Utilize sprockets syntax to include files and folders, ex:
    # By default, everything in javascripts, stylesheets
    # and images are precompiled in the manifest.
    #
    # Example syntax:
    # //= link_tree ../images/nfg_csv_importer
    initializer 'nfg_csv_importer.assets.precompile' do |app|
      app.config.assets.precompile << "#{Engine.root.join('app', 'assets', 'config')}/nfg_csv_importer_manifest.js"
    end
  end
end
