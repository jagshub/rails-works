# frozen_string_literal: true

module Mobile::Graph::Types
  class CommentMediaUploadsInputType < BaseInputObject
    argument :image_data, MediaInputType, required: false
  end
end
