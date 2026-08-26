# Changelog

All notable changes to this gem are documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project uses the version declared in `lib/nfg_csv_importer/version.rb`. Versioning policy: the version tracks the Rails major.minor series the gem supports, while the patch segment is the gem's own release counter — see the Versioning section in the README.

## [7.2.3.1] - 2026-08-26
Released as `7.2.3.1.uat1` through `.uat5` during UAT, then finalized as `7.2.3.1`.

### Changed
- Upgraded Rails from `7.2.2.1` to `~> 7.2.0` (allowing later `7.2.x` patch releases), initially to `7.2.3.1` (resolves several Rails CVEs, including a critical Active Storage advisory and a high-severity Active Storage path traversal advisory both patched at `7.2.3.1`/`7.2.2.2`).
- Switched the `nfg_onboarder` dependency from a git branch (`rails_7_2`) to the published `>= 7.2.3.1` gem version, fetched from the [network-for-good GitHub Packages registry](https://rubygems.pkg.github.com/network-for-good).
- Moved gem dependencies that were declared directly in the `Gemfile` (`nfg_onboarder`, `reform-rails`, `listen`, `better_errors`, `binding_of_caller`) into `nfg_csv_importer.gemspec`, so the gemspec is the single source of truth for the gem's dependencies.
- Fixed `nfg_csv_importer.gemspec`'s `s.files` to also package `vendor/` assets; without this, `application.js.coffee`'s gem-relative `require_directory` of `vendor/assets/javascripts/legacy_browser_support` raised `Sprockets::ArgumentError` in host apps.

### Added
- Added `bin/publish_gem` and a `Releasing` section in the README documenting how to build and push this gem to the network-for-good GitHub Packages registry.
