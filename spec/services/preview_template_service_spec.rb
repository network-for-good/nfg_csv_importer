require 'rails_helper'

describe NfgCsvImporter::PreviewTemplateService do
  let(:preview_template_service) { NfgCsvImporter::PreviewTemplateService.new(import: import) }
  let!(:import) { build(:import, imported_for: build_stubbed(:entity), import_type: :donation) }
  let(:templates) { %w(user donation) }
  let(:macro_templates) { %w(user) }
  let(:columns) { %w(first_name last_name) }
  let(:nfg_csv_importer_to_host_mapping) do
    {
      "amount" => 'amount', "email" => 'email', "address" => 'address', "first_name" => 'first_name', "last_name" => 'last_name',
      "email" => 'email', "phone" => 'home_phone', "address" => 'address', "address_2" => 'address_2', "city" => 'city', "state" => 'state',
      "zip_code" => 'zip_code', "note" => 'user_notes', "transaction_id" => 'transaction_id', "donated_at" => 'donated_at', "campaign" => 'campaign'
    }
  end

  let(:preview_hash) do
    {
      columns_to_show: columns,
      templates_to_render: templates,
      macro_templates_to_render: macro_templates,
      nfg_csv_importer_to_host_mapping: nfg_csv_importer_to_host_mapping
    }
  end

  before { import.expects(:preview_template).returns(preview_hash) }

  describe "#templates_to_render" do
    subject { preview_template_service.templates_to_render }


    it "should return templates to render" do
      expect(subject).to eq(templates)
    end

    context 'when nfg_csv_importer_to_host_mapping is nil' do
      let(:preview_hash) { nil }

      it 'should return nil' do
        expect(subject).to eq([])
      end
    end
  end

  describe "#macro_templates_to_render" do
    subject { preview_template_service.macro_templates_to_render }


    it "should return macro templates to render" do
      expect(subject).to eq(macro_templates)
    end

    context 'when nfg_csv_importer_to_host_mapping is nil' do
      let(:preview_hash) { nil }

      it 'should return nil' do
        expect(subject).to eq([])
      end
    end
  end

  describe "#columns_to_render" do
    subject { preview_template_service.columns_to_render }

    it "should return templates to render" do
      expect(subject).to eq(columns)
    end

    context 'when nfg_csv_importer_to_host_mapping is nil' do
      let(:preview_hash) { nil }

      it 'should return nil' do
        expect(subject).to eq([])
      end
    end
  end

  describe "#nfg_csv_importer_to_host_mapping" do
    subject { preview_template_service.nfg_csv_importer_to_host_mapping }

    it "should return templates to render" do
      expect(subject).to eq(nfg_csv_importer_to_host_mapping)
    end

    context 'when nfg_csv_importer_to_host_mapping is nil' do
      let(:preview_hash) { nil }

      it 'should return nil' do
        expect(subject).to eq({})
      end
    end
  end

  describe "#rows_to_render" do
    subject { preview_template_service.rows_to_render }

    it 'calls rows_with_required_columns' do
      import.expects(:rows_with_required_columns).with(required_rows: 1, required_preview_columns: columns)
      subject
    end
  end
end
