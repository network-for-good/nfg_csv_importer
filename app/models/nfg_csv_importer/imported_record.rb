class NfgCsvImporter::ImportedRecord < ActiveRecord::Base
  belongs_to :imported_by, class_name: NfgCsvImporter.configuration.imported_by_class, foreign_key: :imported_by_id
  belongs_to :imported_for, class_name: NfgCsvImporter.configuration.imported_for_class, foreign_key: :imported_for_id
  belongs_to :importable, :polymorphic => true

  validates_presence_of :imported_by_id, :imported_for_id, :transaction_id, :action

  scope :by_transaction_id,lambda { |transaction_id| includes(:importable).where(transaction_id:transaction_id)}
end
