FactoryGirl.define do
  factory :imported_record, class: NfgCsvImporter::ImportedRecord do
    action "create"
    entity { create(:entity) }
    transaction_id "UNIQUE_ID"
    association :user
    importable { create(:user) }
  end

  factory :import, class: NfgCsvImporter::Import do
    association :entity
    association :user
    import_type 'user'
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
