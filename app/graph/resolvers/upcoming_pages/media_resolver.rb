# frozen_string_literal: true

class Graph::Resolvers::UpcomingPages::MediaResolver < Graph::Resolvers::Base
  type Graph::Types::MediaType, null: true

  def resolve
    return unless object.media

    # NOTE(DZ): Support legacy media fields from UpcomingPageVariant#media jsonb
    OpenStruct.new(
      id: '0',
      uuid: object.media['image_uuid'],
      kind: object.media['media_type'],
      original_width: object.media['original_width'],
      original_height: object.media['original_height'],
      metadata: object.media['metadata'],
    )
  end
end
