class FileUploader < CarrierWave::Uploader::Base

  storage :file
  # belongs_to :file_handler, polymorphic: true

  def store_dir
    "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  end

end