# frozen_string_literal: true

module API::V2Internal::Types
  class SubjectInputType < BaseInputObject
    argument :id, String, required: true
    argument :type, String, required: true
  end
end
