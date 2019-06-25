class NfgCsvImporter::ImportMailerPreview < ActionMailer::Preview
  require 'nfg_csv_importer/mailer_utilities/preview_mailer_controller_transactions_patch'

  def send_import_result
    @status = NfgCsvImporter::ImportMailer::COMPLETED_STATUS

    NfgCsvImporter::ImportMailer.send_import_result(import, @status)
  end

  def send_import_begins_result
    @status = NfgCsvImporter::ImportMailer::BEGIN_STATUS

    NfgCsvImporter::ImportMailer.send_import_result(import, @status)
  end

  def send_import_queued_result
    @status = NfgCsvImporter::ImportMailer::QUEUED_STATUS

    NfgCsvImporter::ImportMailer.send_import_result(import, @status)
  end

  def send_import_completed_result_with_errors
    @status = NfgCsvImporter::ImportMailer::COMPLETED_STATUS

    NfgCsvImporter::ImportMailer.send_import_result(import(error_file: true), @status)
  end

  private

  def recipient
    @recipient = OpenStruct.new(email: 'test@example.com', id: 1)
  end

  def import(error_file: false)
    @import ||= NfgCsvImporter::Import.create!(
      id: 1,
      import_type: 'donation',
      import_file: File.open('spec/fixtures/paypal_processed_file.csv'),
      error_file: (error_file ? File.open('spec/fixtures/errors.xls') : nil),
      number_of_records: 39,
      number_of_records_with_errors: (error_file ? 1 : nil),
      imported_for_id: 1,
      imported_by: @recipient,
      status: @status,
      record_processed: (@status == NfgCsvImporter::ImportMailer::COMPLETED_STATUS ? 39 : nil),
      created_at: Time.now - 10.minutes,
      import_file_name: 'paypal_processed_file.csv',
      processing_started_at: (@status == NfgCsvImporter::ImportMailer::QUEUED_STATUS ? nil : Time.now),
      file_origination_type: 'paypal'
    )
  end
end
