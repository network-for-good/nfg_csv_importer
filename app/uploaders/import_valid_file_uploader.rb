# frozen_string_literal: true

# This class was added to fix an issue where original filename was changing if there was an error
# DM-6662, By adding this class it would only save original filename for a valid file.

class ImportValidFileUploader < ImportFileUploader
  private

  def save_original_filename(file)
    model.import_file_name = file.original_filename if file.respond_to?(:original_filename)
  end
end
