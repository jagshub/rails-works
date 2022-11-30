# frozen_string_literal: true

module Graph::Types
  class Poll::PollOptionsInputType < BaseInputObject
    argument :text, String, required: true
    argument :image_uuid, String, required: false
  end
end
