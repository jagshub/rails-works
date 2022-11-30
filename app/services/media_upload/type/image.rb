# frozen_string_literal: true

module MediaUpload::Type::Image
  extend self

  def call(upload)
    MediaUpload::Info.new image: upload, type: :image
  end
end
