# frozen_string_literal: true

class MediaUpload::Info
  attr_reader(
    :image,
    :metadata,
    :size,
    :type,
  )

  def initialize(image:, type:, size: {}, metadata: nil)
    @image = image
    @type = type
    @size = size
    @metadata = metadata || {}
  end
end
