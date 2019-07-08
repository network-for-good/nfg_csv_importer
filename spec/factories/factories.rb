include ActionDispatch::TestProcess

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

    trait :with_pre_processing_files do
      pre_processing_files { fixture_file_upload("spec/fixtures/paypal_sample_file.xlsx")  }
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

  factory :onboarding_session, class: NfgOnboarder::Session do
    name { 'import_data' }
    association :owner, factory: :user
    association :entity, factory: :entity

    # Session Steps:
    trait :file_origination_type_selection_step do
      current_step { 'file_origination_type_selection' }
    end

    trait :upload_preprocessing_step do
      current_step { 'upload_preprocessing' }
      paypal_file_origination_type
    end

    trait :finish_step do

    end

    # Useful attributes / traits for Onboarding Sessions
    trait :without_step_data do
      step_data { {} }
    end

    trait :paypal_file_origination_type do
      step_data {
        { 'import_data' =>
          { file_origination_type_selection: ActionController::Parameters.new('file_origination_type' => 'paypal') }
        }
      }
    end

    trait :self_import_csv_xls_file_origination_type do
      step_data {
        { 'import_data' =>
          { file_origination_type_selection: ActionController::Parameters.new('file_origination_type' => 'self_import_csv_xls') }
        }
      }
    end

    # NfgOnboarder::Session.new(id: 9, completed_high_level_steps: [], current_step: "upload_preprocessing", owner_id: nil, entity_id: nil, created_at: "2019-07-08 13:46:25", updated_at: "2019-07-08 13:57:07", step_data: {"import_data"=>{:file_origination_type_selection=><ActionController::Parameters {"file_origination_type"=>"paypal"} permitted: true>}}, current_high_level_step: "import_data", onboarder_progress: {"import_data"=>[:file_origination_type_selection]}, owner_type: nil, completed_at: nil, onboarder_prefix: nil, name: "import_data")



    # completed_high_level_steps: [], current_step: "upload_preprocessing", owner_id: nil, entity_id: nil, created_at: "2019-07-05 20:13:37", updated_at: "2019-07-05 20:13:40", step_data: {"import_data"=>{:file_origination_type_selection=><ActionController::Parameters {"file_origination_type"=>"paypal"} permitted: true>}}, current_high_level_step: "import_data", onboarder_progress: {"import_data"=>[:file_origination_type_selection]}, owner_type: nil, completed_at: nil, onboarder_prefix: nil, name: "import_data">]
  end
end
