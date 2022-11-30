# frozen_string_literal: true

module Graph::Types
  class UserLinkInputType < BaseInputObject
    argument :name, String, required: true
    argument :url, String, required: true
    argument :id, ID, required: false
  end
end
