class ImportErrorFileUploader < ImportFileUploader

  def filename
    if original_filename
      @name ||= Digest::MD5.hexdigest(File.dirname(current_path))
      "#{@name}_error.#{file.extension}"
    end
  end
end
