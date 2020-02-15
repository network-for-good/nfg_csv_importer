class ImportFileUploader < CarrierWave::Uploader::Base
  before :cache, :save_original_filename

  def store_dir
    "uploads/#{class_name_for_store_dir}/#{mounted_as}/#{model.id}"
  end

  def class_name_for_store_dir
    model.respond_to?(:class_name_for_store_dir) ? model.class_name_for_store_dir : model.class.to_s.underscore
  end

  def extension_white_list
    %w(csv xls xlsx)
  end

  def filename
    if original_filename
      @name ||= Digest::MD5.hexdigest(File.dirname(current_path))
      "#{@name}.#{file.extension}"
    end
  end

  private

  def save_original_filename(file)
    model.import_file_name = file.original_filename if file.respond_to?(:original_filename)
  end
end
