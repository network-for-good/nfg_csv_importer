class NfgCsvImporter::ImportMailer < ActionMailer::Base
  def send_import_result(import)
    @import     = import
    @recipient = import.imported_by
    mail(
      to: @recipient.email,
      subject: "Your #{@import.import_type} import has completed!",
      from: NfgCsvImporter.configuration.from_address,
      reply_to: NfgCsvImporter.configuration.reply_to_address
    )
  end
end
