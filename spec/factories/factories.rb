FactoryGirl.define do
  factory :imported_record, class: NfgCsvImporter::ImportedRecord do
    action "create"
    imported_for { create(:entity) }
    transaction_id "UNIQUE_ID"
    association :imported_by, factory: :user
    importable { create(:user) }
  end

  factory :import, class: NfgCsvImporter::Import do
    association :imported_for, factory: :entity
    association :imported_by, factory: :user
    import_file { File.open("spec/fixtures/subscribers.csv") }
    import_type 'users'
    status nil
  end
end
