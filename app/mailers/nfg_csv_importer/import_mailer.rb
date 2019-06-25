class NfgCsvImporter::ImportMailer < ActionMailer::Base
  BEGIN_STATUS = 'begun'
  QUEUED_STATUS = 'queued'
  COMPLETED_STATUS = 'completed'

  def send_import_result(import, status = COMPLETED_STATUS)
    @import = import.reload
    @recipient = import.imported_by
    @imported_for = imported_for(@import)
    @url_options = url_options(@imported_for)

    mail(
      to: @recipient.email,
      subject: "Your #{@import.import_type} import has #{status}!",
      from: NfgCsvImporter.configuration.from_address,
      reply_to: NfgCsvImporter.configuration.reply_to_address
    )
  end

  alias send_import_status send_import_result

  def send_destroy_result(import)
    @import = import
    @recipient = import.imported_by
    @imported_for = imported_for(@import)

    mail(
      to: @recipient.email,
      subject: "Your #{@import.import_type} import has been deleted.",
      from: NfgCsvImporter.configuration.from_address,
      reply_to: NfgCsvImporter.configuration.reply_to_address
    )
  end

  private

  def imported_for(import)
    NfgCsvImporter.configuration.imported_for_class.constantize.find(import.imported_for_id)
  end

  def url_options(imported_for)
    options = Rails.application.config.action_mailer.default_url_options.merge(
      subdomain: @imported_for.send(NfgCsvImporter.configuration.imported_for_subdomain),
      only_path: false
    )
    options[:protocol] = 'https' if Rails.env.production?
    options[:port] = '3000' if Rails.env.development?
    options
  end
end
