class NfgCsvImporter::ImportedRecord < ActiveRecord::Base
  belongs_to :imported_by, class_name: NfgCsvImporter.configuration.user_class
  belongs_to :entity, class_name: NfgCsvImporter.configuration.entity_class
  belongs_to :importable, :polymorphic => true

  validates_presence_of :imported_by_id, :transaction_id, :action, NfgCsvImporter.configuration.entity_field

  scope :by_transaction_id,lambda { |transaction_id| includes(:importable).where(transaction_id:transaction_id)}

end
