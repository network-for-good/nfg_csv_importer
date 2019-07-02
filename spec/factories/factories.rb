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
    import_type { 'users' }
    status { nil }

    trait :is_paypal do
      file_origination_type { 'paypal' }
      import_file { File.open("spec/fixtures/paypal_processed_file.csv") }
      import_type { 'donation' }
    end

    trait :is_complete_with_errors do
      is_complete
      error_file { File.open("spec/fixtures/errors.xls") }
      number_of_records_with_errors { CSV.foreach(error_file, headers: true).count }
    end

    trait :is_processing do
      status { :processing }
      processing_started_at { 10.minutes.ago }
    end

    trait :is_complete do
      status { :complete }
      processing_started_at { 10.minutes.ago }
      processing_finished_at { 1.minute.ago }
      records_processed { CSV.foreach(import_file, headers: true).count }
    end

    trait :is_queued do
      status { :queued }
      processing_started_at { 10.minutes.ago }
    end

    trait :pending do
      status { :pending }
      import_type nil
      import_file nil
    end


  end
end
