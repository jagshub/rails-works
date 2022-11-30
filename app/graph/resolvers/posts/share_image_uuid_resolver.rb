# frozen_string_literal: true

class Graph::Resolvers::Posts::ShareImageUuidResolver < Graph::Resolvers::Base
  type String, null: false

  def resolve
    object.social_media_image_uuid || object.images.by_priority.first&.uuid || object.thumbnail_image_uuid
  end
end
