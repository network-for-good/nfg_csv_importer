require 'rails_helper'

describe NfgCsvImporter::ImportedRecord do
  it { should validate_presence_of(:imported_by_id) }
  it { should validate_presence_of(:imported_for_id)}
  it { should validate_presence_of(:action) }
  it { should validate_presence_of(:transaction_id) }
  it { should belong_to(:imported_by) }
  it { should belong_to(:imported_for) }
  it { should belong_to(:importable) }

  shared_examples_for "deleting an imported record" do
    it "deletes the user record" do
      expect { imported_record.destroy }.to change(importable.class, :count).by(-1)
    end

    it "deletes itself" do
      imported_record.destroy
      expect(imported_record.destroyed?).to be_truthy
    end

    it { is_expected.to be_truthy }
  end

  describe "destroying imported records" do
    let(:imported_for) { create(:entity) }
    let!(:importable) { create(:user, entity: imported_for) }
    let!(:imported_record) { create(:imported_record, importable: importable, imported_for: imported_for) }

    context "when the importable does not respond to #can_be_destroyed?" do
      it_behaves_like "deleting an imported record"
    end

    context "when the importable can be destroyed" do
      before { importable.stubs(:can_be_destroyed?).returns(true) }
      it_behaves_like "deleting an imported record"
    end

    context "when the importable cannot be destroyed" do
      before { importable.stubs(:can_be_destroyed?).returns(false) }

      it "does not delete the record" do
        expect { imported_record.destroy_importable! }.not_to change(importable.class, :count)
      end

      it "does not delete itself" do
        imported_record.destroy_importable!
        expect(imported_record.deleted?).to be_falsey
      end

      it 'should return false' do
        expect(imported_record.destroy_importable!).to be_falsey
      end
    end

    context "when the importable no longer exists" do
      before do
        importable.destroy
      end

      it "does not raise an exception" do
        expect { imported_record.reload.destroy_importable! }.not_to raise_exception
      end

      it "sets deleted attribute to 'true'" do
        # resolves https://jira.networkforgood.org/browse/DM-7619
        imported_record.reload.destroy_importable!
        expect(imported_record).to be_deleted
      end
    end

    context "when the importable belongs to a different imported_for" do
      let(:other_imported_for) { create(:entity) }
      let!(:importable) { create(:user, entity: other_imported_for) }
      let!(:imported_record) { create(:imported_record, importable: importable, imported_for: imported_for) }

      it "does not destroy the importable" do
        imported_record.destroy_importable!
        expect(importable.destroyed?).to be_falsey
      end
    end
  end
end
