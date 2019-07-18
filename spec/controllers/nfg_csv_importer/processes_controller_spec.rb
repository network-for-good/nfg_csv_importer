require 'rails_helper'

describe NfgCsvImporter::ProcessesController do

  let(:entity) { create(:entity) }
  let(:params) { { params: { id: import.id, use_route: :nfg_csv_importer } } }
  let!(:import) { create(:import, imported_for: entity, status: 'uploaded') }

  render_views

  describe "#create" do
    subject { post :create, params }

    context "when the import is valid" do
      it 'enqueues a queued status email' do
        NfgCsvImporter::ImportMailer.expects(:send_import_result).returns(mock('import_result', deliver_now: nil))
        NfgCsvImporter::ProcessImportJob.expects(:perform_later)
        subject
      end
    end
  end
end
