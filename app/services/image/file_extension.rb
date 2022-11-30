# frozen_string_literal: true

module Image::FileExtension
  extend self

  MIME_TO_EXTENSION = {
    'svg+xml' => 'svg',
  }.freeze

  # Note(Rahul): We get file extension from MIME type & for certain cases like svg
  #              it's image/svg+xml & we should have extension as svg! Hence the mapping.
  #
  #              content_type examples image/png image/svg+xml
  def call(content_type)
    mime_type = content_type.split('/').last

    MIME_TO_EXTENSION[mime_type] || mime_type
  end
end
