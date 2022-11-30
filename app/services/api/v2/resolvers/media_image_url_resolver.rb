# frozen_string_literal: true

module API::V2::Resolvers
  class MediaImageUrlResolver < BaseResolver
    type String, null: false

    argument :width, Int, 'Set width of the image to given value.', required: false
    argument :height, Int, 'Set height of the image to given value.', required: false

    def resolve(width: nil, height: nil)
      Image.call(object.uuid, width: width, height: height)
    end
  end
end
