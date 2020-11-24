class NfgCsvImporter::ImportedRecord < ActiveRecord::Base
  attr_accessor :destroy_stats

  serialize :row_data, Hash

  belongs_to :import
  belongs_to :imported_by, class_name: NfgCsvImporter.configuration.imported_by_class, foreign_key: :imported_by_id
  belongs_to :imported_for, class_name: NfgCsvImporter.configuration.imported_for_class, foreign_key: :imported_for_id
  belongs_to :importable, polymorphic: true, dependent: :destroy

  validates_presence_of :imported_by_id, :imported_for_id, :transaction_id, :action, :importable_id, :importable_type

  scope :by_transaction_id,lambda { |transaction_id| includes(:importable).where(transaction_id:transaction_id)}
  scope :created, -> { where(action: 'create') }

  NON_DELETABLE_ACTION = 'non_deletable'

  def self.batch_size
    500
  end

  def destroy_importable!
    self.destroy_stats = {}

    # don't bother doing anything if there's no importable
    if self.importable.present?
      # This is an importable instance method where we can supply criteria
      # to block deletion. The DM user model has this method.
      if importable.respond_to?(:can_be_destroyed?)
        if importable.can_be_destroyed?
          destroy_imported_record
        else
          # If the importable can't be destroyed, log it and return.
          log_importable_to(:undestroyable)
          return false
        end
      else
        # If the importable doesn't respond to :can_be_destroyed?, then we'll
        # we can delete it.
        destroy_imported_record
      end
    end
    true
  end

  def created?
    action == 'create'
  end

  private

  def destroy_imported_record
    imported_for_association = NfgCsvImporter.configuration.imported_for_class.downcase

    # imported_for is Site in DM, Entity in Evo. If the importable doesn't respond to this
    # association, then we're bailing immediately because we can't do the next evaluation.
    unless importable.respond_to?(imported_for_association)
      log_importable_to(:no_imported_for_assoc)
      return false
    end

    # This checks to make sure the importable belongs to the same site or entity (imported_for)
    # to which the import belongs. If not, we don't delete the record.
    unless importable.send(imported_for_association).id == imported_for_id
      log_importable_to(:mismatched_owner_ids)
      return false
    end

    importable.destroy
    self.update(deleted: true)
    log_importable_to(:destroyed)
  end

  def log_importable_to(stat_type)
    destroy_stats[stat_type] = "#{importable_type}/#{importable_id}"
  end
end
