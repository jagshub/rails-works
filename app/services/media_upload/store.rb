# frozen_string_literal: true

module MediaUpload::Store
  extend self

  def call(upload, types)
    info = fetch_info(types, upload)
    result = Image::Upload.call(info.image)

    MediaUpload::File.new(
      image_uuid: result[:image_uuid],
      original_width: info.size[:original_width].presence || result[:original_width],
      original_height: info.size[:original_height].presence || result[:original_height],
      media_type: info.type,
      metadata: info.metadata,
    )
  rescue Image::Upload::FormatError => e
    raise MediaUpload::UploadError, 'Error while uploading: ' + e.message
  rescue Errno::ECONNRESET
    raise MediaUpload::UploadError, 'Network error, please try again'
  end

  private

  def fetch_info(types, upload)
    types.each do |type|
      result = type.call upload
      return result unless result.nil?
    end

    missing_image
  end

  # Note(andreasklinger): Technically Types::Image acts as catch-all.
  #   But for correctness we keep this fallback here.
  #   In anycase Image::Upload will fail w/ FormatError for a non-correct image
  def missing_image
    MediaUpload::Info.new(image: nil, type: :image)
  end
end
