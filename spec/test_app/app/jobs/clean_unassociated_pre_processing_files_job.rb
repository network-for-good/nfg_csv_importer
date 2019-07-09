class CleanUnassociatedPreProcessingFilesJob < ApplicationJob
  queue_as :default

  def perform(*args)
    ActiveStorage::Blob.left_outer_joins(:attachments).where(
      active_storage_attachments: { blob_id: nil }).
      where("date(active_storage_blobs.created_at) < ?", 1.day.ago.to_date).each do |blob|
        blob.purge
    end
  end
end
