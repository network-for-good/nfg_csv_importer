# frozen_string_literal: true

class ImportValidFileUploader < ImportFileUploader
  private

  def save_original_filename(file)
    model.import_file_name = file.original_filename if file.respond_to?(:original_filename)
  end
end
