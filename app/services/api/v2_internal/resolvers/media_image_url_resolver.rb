# frozen_string_literal: true

class API::V2Internal::Resolvers::MediaImageUrlResolver < Graph::Resolvers::Base
  argument :width, Int, required: false
  argument :height, Int, required: false

  type String, null: false

  def resolve(args = {})
    Image.call(object.uuid, width: args[:width], height: args[:height])
  end
end
