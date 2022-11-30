# frozen_string_literal: true

module S3Helper
  def s3_image_tag(source, options = {})
    image_tag S3Helper.image_url(source), options
  end

  class << self
    def url(path)
      "https://ph-static.imgix.net/#{ path }"
    end

    def image_url(source)
      url source
    end
  end
end
