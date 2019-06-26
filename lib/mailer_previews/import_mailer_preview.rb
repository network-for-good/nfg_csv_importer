class NfgCsvImporter::ImportMailerPreview < ActionMailer::Preview
  require 'nfg_csv_importer/mailer_utilities/preview_mailer_controller_transactions_patch'

  def send_import_result_begins
    @status = NfgCsvImporter::ImportMailer::BEGIN_STATUS

    NfgCsvImporter::ImportMailer.send_import_result(import, @status)
  end

  def send_import_result_queued
    @status = NfgCsvImporter::ImportMailer::QUEUED_STATUS

    NfgCsvImporter::ImportMailer.send_import_result(import, @status)
  end

  def send_import_result_completed
    @status = NfgCsvImporter::ImportMailer::COMPLETED_STATUS

    NfgCsvImporter::ImportMailer.send_import_result(import(error_file: true), @status)
  end

  def send_import_result_completed_with_errors
    @status = NfgCsvImporter::ImportMailer::COMPLETED_STATUS

    NfgCsvImporter::ImportMailer.send_import_result(import(error_file: true), @status)
  end

  private

  def recipient
    @recipient ||= FactoryGirl.create(:user, entity: entity)
  end

  def entity
    @entity ||= FactoryGirl.create(:entity)
  end

  def import(error_file: false)
    @import ||= NfgCsvImporter::Import.create!(
      import_type: 'donation',
      import_file: File.open("#{NfgCsvImporter::Engine.root}/spec/fixtures/paypal_processed_file.csv"),
      error_file: (error_file ? File.open("#{NfgCsvImporter::Engine.root}/spec/fixtures/errors.xls") : nil),
      number_of_records: 39,
      number_of_records_with_errors: (error_file ? 1 : nil),
      imported_for: entity,
      imported_by: recipient,
      status: @status,
      records_processed: (@status == NfgCsvImporter::ImportMailer::COMPLETED_STATUS ? 39 : nil),
      created_at: Time.now - 10.minutes,
      import_file_name: 'paypal_processed_file.csv',
      processing_started_at: (@status == NfgCsvImporter::ImportMailer::QUEUED_STATUS ? nil : Time.now),
      file_origination_type: 'paypal'
    )
  end
end
