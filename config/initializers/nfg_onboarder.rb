NfgOnboarder.setup do |config|
  # this allows the UrlGenerator in the Onboarder
  # to generate the correct routes
  config.router_name = :nfg_csv_importer
end