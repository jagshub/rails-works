# frozen_string_literal: true

module Graph::Mutations
  class UploadMedia < BaseMutation
    argument :file, String, required: true

    returns Graph::Types::MediaUploadType

    def perform(file:)
      media = MediaUpload.store(file)

      if media
        success media
      else
        error :base, 'Media upload failed'
      end
    rescue MediaUpload::UploadError
      error :base, 'Media upload failed'
    end
  end
end
