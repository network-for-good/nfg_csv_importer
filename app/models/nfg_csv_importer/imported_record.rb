class NfgCsvImporter::ImportedRecord < ActiveRecord::Base
  belongs_to :import
  belongs_to :imported_by, class_name: NfgCsvImporter.configuration.imported_by_class, foreign_key: :imported_by_id
  belongs_to :imported_for, class_name: NfgCsvImporter.configuration.imported_for_class, foreign_key: :imported_for_id
  belongs_to :importable, polymorphic: true, dependent: :destroy

  validates_presence_of :imported_by_id, :imported_for_id, :transaction_id, :action, :importable_id, :importable_type

  scope :by_transaction_id,lambda { |transaction_id| includes(:importable).where(transaction_id:transaction_id)}
  scope :created, -> { where(action: 'create') }

  def destroy
    if importable.respond_to?(:can_be_destroyed?)
      if importable.can_be_destroyed?
        importable.destroy
        super
      else
        return
      end
    else
      importable.destroy
      super
    end
  end
end
