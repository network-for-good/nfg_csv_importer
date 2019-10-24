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
    import_file { File.open("#{NfgCsvImporter::Engine.root}/spec/fixtures/subscribers.csv") }
    import_type { 'users' }
    file_origination_type { 'self_import_csv_xls' }
    status { nil }

    trait :is_paypal do
      file_origination_type { 'paypal' }
      import_file { File.open("#{NfgCsvImporter::Engine.root}/spec/fixtures/paypal_processed_file.csv") }
      import_type { 'donation' }
    end

    trait :with_pre_processing_files do
      pre_processing_files { fixture_file_upload("spec/fixtures/paypal_sample_file.xlsx")  }
    end

    trait :with_multiple_pre_processing_files do
      pre_processing_files do
        [fixture_file_upload("spec/fixtures/paypal_sample_file.xlsx"),
        fixture_file_upload("spec/fixtures/paypal_sample_file.xlsx")]
      end
    end

    trait :is_complete_with_errors do
      is_complete
      error_file { File.open("#{NfgCsvImporter::Engine.root}/spec/fixtures/errors.xls") }
      number_of_records_with_errors { CSV.foreach(error_file, headers: true).count }
      number_of_records { records_processed.to_i - number_of_records_with_errors.to_i }
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
      number_of_records { records_processed }
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

    trait :with_statistics do
      statistics {{"summary_data" => { "number_of_rows" => 4 }, "example_rows" => [ { "donated_at" => "2016-05-07 18:30:09 UTC", "full_name" => "Ian Mowbray", "amount" => "35", "email" => "Ian_Mowbray@nfg.com", "transaction_id" => "09B930045X391394D", "address" => "3555 Bristol Breeze Lane", "address_2" => nil, "city" => "Rockville", "state" => "MD", "zip_code" => "77573", "country" => "United States", "home_phone" => nil, "description" => nil, "payment_method" => "Paypal"}, {"donated_at" => "2016-05-27 13:21:59 UTC", "full_name" => "info2@NFG.org", "amount" => "22", "email" => "info2@NFG.org", "transaction_id" => "70S7423316828942V", "payment_method"=>"Paypal" }] }}
    end
  end

  # Note: to use an onboarding session it may require stubbing the controller params
  # add this to your spec if you encounter the following error:
  #
  # Failure/Error: active_step = view.params[:id]
  # NoMethodError:
  # undefined method `parameters' for nil:NilClass
  #
  # Solution:
  # 1. Generate the session with something like these `let` variables:
  # let(:onboarding_session) { FactoryGirl.create(:onboarding_session, :"#{current_step}_step") }
  # let(:current_step) { 'file_origination_type_selection' }
  #
  # 2. Then stub the controller so that the presenter and session are married:
  # before { h.controller.stubs(:params).returns(id: current_step) }
  #
  # Note: `h` is view_context, like: ApplicationController.new.view_context
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
      current_step { 'finish' }
      paypal_file_origination_type
    end

    trait :preview_confirmation_step do
      current_step { 'preview_confirmation' }
      paypal_file_origination_type
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

    trait :with_note do
      send_to_nfg_file_origination_type

      after :build do |onboarding_session|
        onboarding_session.step_data['import_data'] = { upload_preprocessing: { 'note' => 'test note' } }
      end
    end

    trait :self_import_csv_xls_file_origination_type do
      step_data {
        { 'import_data' =>
          { file_origination_type_selection: ActionController::Parameters.new('file_origination_type' => 'self_import_csv_xls') }
        }
      }
    end

    trait :send_to_nfg_file_origination_type do
      step_data {
        { 'import_data' =>
          { file_origination_type_selection: ActionController::Parameters.new('file_origination_type' => 'send_to_nfg') }
        }
      }
    end
  end
end
