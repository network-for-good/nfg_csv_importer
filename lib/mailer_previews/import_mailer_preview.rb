class NfgCsvImporter::ImportMailerPreview < ActionMailer::Preview
  require 'nfg_csv_importer/mailer_utilities/preview_mailer_controller_transactions_patch'

  def send_import_result_processing
    @status = NfgCsvImporter::Import::PROCESSING_STATUS
    @recipient = recipient

    NfgCsvImporter::ImportMailer.send_import_result(import)
  end

  def send_import_result_queued
    @status = NfgCsvImporter::Import::QUEUED_STATUS
    @recipient = recipient

    NfgCsvImporter::ImportMailer.send_import_result(import)
  end

  def send_import_result_completed
    @status = NfgCsvImporter::Import::COMPLETED_STATUS
    @recipient = recipient

    NfgCsvImporter::ImportMailer.send_import_result(import)
  end

  def send_import_result_completed_with_errors
    @status = NfgCsvImporter::Import::COMPLETED_STATUS
    @recipient = recipient

    NfgCsvImporter::ImportMailer.send_import_result(import(errors: true))
  end

  def send_import_result_deleted
    @status = NfgCsvImporter::Import::COMPLETED_STATUS
    @recipient = recipient

    NfgCsvImporter::ImportMailer.send_import_result(import)
  end

  private

  def recipient
    @recipient ||= FactoryBot.create(:user, entity: entity)
  end

  def entity
    @entity ||= Entity.last || FactoryBot.create(:entity)
  end

  def import(errors: false, file_origination_type: 'paypal')
    error_file = errors ? File.open("#{NfgCsvImporter::Engine.root}/spec/fixtures/errors.csv") : nil
    number_of_records_with_errors = error_file ? 1 : nil
    import_file = File.open("#{NfgCsvImporter::Engine.root}/spec/fixtures/paypal_processed_file.csv")
    records_processed = @status == NfgCsvImporter::Import::COMPLETED_STATUS ? 39 : nil
    processing_started_at = @status == NfgCsvImporter::Import::QUEUED_STATUS ? nil : Time.now

    @import ||= NfgCsvImporter::Import.create!(
      import_type: 'donation',
      import_file: import_file,
      error_file: error_file,
      number_of_records: 39,
      number_of_records_with_errors: number_of_records_with_errors,
      imported_for: @recipient.entity,
      imported_by: @recipient,
      status: @status,
      records_processed: records_processed,
      created_at: Time.now - 10.minutes,
      import_file_name: 'paypal_processed_file.csv',
      processing_started_at: processing_started_at,
      file_origination_type: file_origination_type
    )
  end
end
