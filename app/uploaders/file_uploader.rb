class FileUploader < CarrierWave::Uploader::Base

  storage :file
  # belongs_to :file_handler, polymorphic: true

  def store_dir
    if Rails.env.test? || Rails.env.cucumber?
      "#{Rails.root}/public/test/input_file_uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    else
      "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
      # "#{Rails.root}/public/input_files/#{model.id}"
    end
  end

end

class String
  # ruby mutation methods have the expectation to return self if a mutation occurred, nil otherwise.
  # (see http://www.ruby-doc.org/core-1.9.3/String.html#method-i-gsub-21)

  def to_underscore!
    gsub!(/(.)([A-Z])/,'\1_\2')
    downcase!
  end

  def to_underscore
    dup.tap { |s| s.to_underscore! }
  end
end