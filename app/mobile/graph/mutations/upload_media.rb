# frozen_string_literal: true

module Mobile::Graph::Mutations
  class UploadMedia < BaseMutation
    argument :file, String, required: true

    returns Mobile::Graph::Types::MediaType

    require_current_user

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
