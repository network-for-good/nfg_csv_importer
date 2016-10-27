class NfgCsvImporter::ImportedRecord < ActiveRecord::Base
  attr_accessor :destroy_stats

  belongs_to :import
  belongs_to :imported_by, class_name: NfgCsvImporter.configuration.imported_by_class, foreign_key: :imported_by_id
  belongs_to :imported_for, class_name: NfgCsvImporter.configuration.imported_for_class, foreign_key: :imported_for_id
  belongs_to :importable, polymorphic: true, dependent: :destroy

  validates_presence_of :imported_by_id, :imported_for_id, :transaction_id, :action, :importable_id, :importable_type

  scope :by_transaction_id,lambda { |transaction_id| includes(:importable).where(transaction_id:transaction_id)}
  scope :created, -> { where(action: 'create') }

  def self.batch_size
    500
  end

  def destroy
    self.destroy_stats = {}
    if self.importable.present?
      if importable.respond_to?(:can_be_destroyed?)
        if importable.can_be_destroyed?
          destroy_importable! && super
        else
          log_importable_to(:undestroyable)
          return
        end
      else
        destroy_importable! && super
      end
    else
      super
    end
  end

  def created?
    action == 'create'
  end

  private

  def destroy_importable!
    imported_for_association = NfgCsvImporter.configuration.imported_for_class.downcase

    unless importable.respond_to?(imported_for_association)
      log_importable_to(:no_imported_for_assoc)
      return false
    end

    unless importable.send(imported_for_association).id == imported_for_id
      log_importable_to(:mismatched_owner_ids)
      return false
    end

    importable.destroy
    log_importable_to(:destroyed)
  end

  def log_importable_to(stat_type)
    destroy_stats[stat_type] = "#{importable_type}/#{importable_id}"
  end
end
