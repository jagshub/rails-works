# frozen_string_literal: true

module Mobile::Graph::Resolvers
  class AWSDirectUploadUrlResolver < BaseResolver
    argument :extension, String, required: true

    ALLOWED_EXTENSIONS = ['jpg', 'jpeg', 'png', 'gif', 'jfif', 'pjpeg', 'pjp'].freeze

    def resolve(extension:)
      unless ALLOWED_EXTENSIONS.include?(extension)
        return
      end

      External::S3Api.presign(extension)
    end
  end
end
