# frozen_string_literal: true

module Mobile::Graph::Types
  class PollOptionsInputType < BaseInputObject
    argument :text, String, required: true
    argument :image_uuid, String, required: false
  end
end
