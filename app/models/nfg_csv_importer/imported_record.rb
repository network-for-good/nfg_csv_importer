class NfgCsvImporter::ImportedRecord < ActiveRecord::Base
  belongs_to :admin
  belongs_to :entity
  belongs_to :importable, :polymorphic => true

  validates_presence_of :admin_id,:transaction_id,:action,:entity_id

  scope :by_transaction_id,lambda { |transaction_id| includes(:importable).where(transaction_id:transaction_id)}

end
