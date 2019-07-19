class NfgCsvImporter::ImportMailer < ActionMailer::Base
  require "nfg_csv_importer/mailer_utilities/email_inlineable"
  include NfgCsvImporter::MailerUtilities::EmailInlineable

  layout 'nfg_csv_importer/layouts/mailer'

  def send_import_result(import)
    @import = import.reload
    @recipient = import.imported_by
    @imported_for = imported_for(@import)
    @url_options = url_options
    @locales_scope = [:mailers, :nfg_csv_importer, :send_import_result_mailer]
    @import_mailer_presenter = NfgCsvImporter::Mailers::ImportMailerPresenter.new(@import, self.view_context)

    mail(
      to: @recipient.email,
      subject: "Your import is #{@import.status}#{show_excitement}",
      from: NfgCsvImporter.configuration.from_address,
      reply_to: NfgCsvImporter.configuration.reply_to_address,
      skip_premailer: true
    ) do |format|
      format.html { inlined_html }
    end
  end

  alias send_import_status send_import_result

  def path
    @path ||= "#{self.controller_path}/#{self.action_name}_#{@import.status}"
  end

  private

  def imported_for(import)
    NfgCsvImporter.configuration.imported_for_class.constantize.find(import.imported_for_id)
  end

  def show_excitement
    @import.deleted? ? '' : "!"
  end

  def url_options
    options = Rails.application.config.action_mailer.default_url_options.merge(
      subdomain: @imported_for.send(NfgCsvImporter.configuration.imported_for_subdomain),
      only_path: false
    )
    options[:protocol] = 'https' if Rails.env.production?
    options[:port] = '3000' if Rails.env.development?
    options[:host] = 'lvh.me' if Rails.env.test?
    options
  end
end
