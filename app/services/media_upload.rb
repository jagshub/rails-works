# frozen_string_literal: true

module MediaUpload
  extend self

  ALL_TYPES = [
    MediaUpload::Type::Video,
    MediaUpload::Type::Image,
  ].freeze

  def store(upload, types = ALL_TYPES)
    MediaUpload::Store.call(upload, types)
  end
end
