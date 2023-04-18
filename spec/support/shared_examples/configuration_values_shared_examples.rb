shared_examples_for "setting custom configuration values" do
  subject { described_class.sidekiq_options }

  # The configuration values used below are set in spec/test_app/config/initializers/nfg_csv_importer.rb

  if described_class == NfgCsvImporter::ProcessImportJob
    describe "high_priority_queue_name" do
      let(:high_priority_queue_name) { :my_fine_queue }
      it { should include("queue" => high_priority_queue_name) }
    end

    describe "process_import_job_sidekiq_options" do
      let(:process_import_job_sidekiq_options) { { "unique_for" => 30.minutes } }
      it { should include(process_import_job_sidekiq_options) }
    end
  end

  if described_class == NfgCsvImporter::DestroyImportJob
    describe "destroy_import_job_sidekiq_options" do
      let(:destroy_import_job_sidekiq_options) { { "backtrace" => true } }
      it { should include(destroy_import_job_sidekiq_options) }
    end
  end
end
