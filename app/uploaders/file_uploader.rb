class FileUploader < CarrierWave::Uploader::Base

  storage :file
  # belongs_to :file_handler, polymorphic: true

  def store_dir
    if Rails.env.test? || Rails.env.cucumber?
      "#{Rails.root}/public/test/input_file_uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    else
      "#{Rails.root}/public/input_files/#{model.id}"
    end
  end

  # def store_dir
  #   "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
  # end

end