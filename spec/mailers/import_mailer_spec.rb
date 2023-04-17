require "rails_helper"

describe NfgCsvImporter::ImportMailer, type: :mailer do
  let(:import) { FactoryBot.create(:import, *import_traits) }

  describe "#send_import_result" do
    before { @import = import } # for the view
    let(:import_traits) { [:is_paypal, :is_complete] }
    # For standard view spec type testing
    let(:rendered_body) { Capybara.string(subject.body.raw_source) }

    let(:send_import_result_mailer) { NfgCsvImporter::ImportMailer.send_import_result(@import) }

    subject { send_import_result_mailer.deliver_now }

    it { expect(subject.subject).to eq("Your import is complete!") }

    it { expect(Rails.configuration.default_from_address).to match(subject.from.first) }

    it { expect(subject.to).to eq([import.imported_by.email])}

    it 'is an import result mailer' do
      and_it 'says hello to the recipient' do
        expect(rendered_body).to have_selector '#hello', text: import.imported_by.first_name
      end
    end

    describe 'mailer adjustments based on import status' do

      context 'when the import status is :queued' do
        let(:import_traits) { [:is_paypal, :is_queued] }
        it 'communicates the import status is queued' do
          by 'showing an active first step image' do
            expect(rendered_body).to have_css "img#queued_milestone_image[src*='fa-check-circle-success']"
          end

          and_it 'does not activate the second and third step images' do
            expect(rendered_body).to have_css "img#processing_milestone_image[src*='disabled-circle-2']"

            expect(rendered_body).to have_css "img#complete_milestone_image[src*='disabled-circle-3']"
          end

          and_by 'communicating language about the status' do
            expect(rendered_body).to have_selector '#introduction', text: I18n.t("mailers.nfg_csv_importer.send_import_result_mailer.body.introduction.queued")

            expect(rendered_body).to have_selector '#what_to_expect', text: I18n.t("mailers.nfg_csv_importer.send_import_result_mailer.body.what_to_expect.queued")
          end
        end
      end

      context 'when the import status is :processing' do
        let(:import_traits) { [:is_paypal, :is_processing] }

        it 'communicates the import status is processing' do
          by 'showing the first two steps as activated' do
            expect(rendered_body).to have_css "img#queued_milestone_image[src*='fa-check-circle-success']"

            expect(rendered_body).to have_css "img#processing_milestone_image[src*='fa-check-circle-success']"
          end

          and_it 'does not activate the third step image' do
            expect(rendered_body).to have_css "img#complete_milestone_image[src*='disabled-circle-3']"
          end

          and_by 'communicating language about the status' do
            expect(rendered_body).to have_selector '#introduction', text: I18n.t("mailers.nfg_csv_importer.send_import_result_mailer.body.introduction.processing")

            expect(rendered_body).to have_selector '#what_to_expect', text: I18n.t("mailers.nfg_csv_importer.send_import_result_mailer.body.what_to_expect.processing")
          end
        end
      end

      context 'when the import status is :complete' do
        let(:import_traits) { [:is_paypal, :is_complete] }

        it 'communicates the import status is complete' do
          by 'removing the steps' do
            expect(rendered_body).not_to have_css 'img#queued_milestone_image'
            expect(rendered_body).not_to have_css 'img#processing_milestone_image'
            expect(rendered_body).not_to have_css 'img#complete_milestone_image'
          end

          and_it 'renders an illustration instead' do
            expect(rendered_body).to have_css "img#finish_success_image"
          end

          and_by 'communicating language about the status' do
            expect(rendered_body).to have_selector '#introduction', text: I18n.t("mailers.nfg_csv_importer.send_import_result_mailer.body.introduction.complete")

            expect(rendered_body).to have_selector '#what_to_expect', text: I18n.t("mailers.nfg_csv_importer.send_import_result_mailer.body.what_to_expect.complete")
          end
        end

        context 'and when the import is complete without errors' do
          it 'does not show error information' do
            and_it 'excludes an error count in the number of records summary' do
              expect(rendered_body).not_to have_css '#number_of_records #error_records_count_of_total'
            end

            and_it 'does not render the alert' do
              expect(rendered_body).not_to have_css '.callout'
            end
          end
        end

        context 'and when the import is complete with errors' do
          let(:import_traits) { [:is_paypal, :is_complete_with_errors] }
          it 'shows all steps' do
            expect(rendered_body).to have_css "img#queued_milestone_image[src*='fa-check-circle-success']"

            expect(rendered_body).to have_css "img#processing_milestone_image[src*='fa-check-circle-success']"

            expect(rendered_body).to have_css "img#complete_milestone_image[src*='fa-check-circle-success']"

            and_it 'does not show the illustration' do
              expect(rendered_body).not_to have_css "img#finish_success_image"
            end
          end

          it 'shows error information' do
            and_it 'includes an error count in the number of records summary' do
              expect(rendered_body).to have_selector '#number_of_records #error_records_count_of_total', text: '1 record'
            end

            and_it 'renders the alert' do
              expect(rendered_body).to have_selector '.warning.callout-inner', text: I18n.t("mailers.nfg_csv_importer.send_import_result_mailer.alert.error")
            end

            and_it 'includes a link to download the error file' do
              expect(rendered_body).to have_css "a#error_link"
              href = NfgCsvImporter::Engine.routes.url_helpers.import_url(import, host: 'lvh.me:3000', subdomain: import.imported_for.subdomain)
              expect(subject.body.encoded).to have_link('error_link', href: href)
              # expect(subject.body.encoded).to match(%Q{test.example.com})
              # expect(subject.body.encoded).to match("nfg_csv_importer/#{import.id}")
            end
          end
        end
      end
    end
  end
end

