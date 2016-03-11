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
    import_type 'user'
    status nil
  end

  factory :entity do
  end

  factory :project do
  end

  factory :user do
    first_name "Joe"
    last_name "Schmoe"
    email "user@example.com"
  end
end
