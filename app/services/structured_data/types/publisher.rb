# frozen_string_literal: true

module StructuredData::Types::Publisher
  extend self

  def call
    {
      "@type": 'Organization',
      "name": 'Product Hunt',
      "logo": {
        "@type": 'ImageObject',
        "url": S3Helper.image_url('ph-publisher-logo.png'),
        "width": 220,
        "height": 60,
      },
    }
  end
end
