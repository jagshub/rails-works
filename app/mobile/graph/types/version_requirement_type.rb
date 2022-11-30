# frozen_string_literal: true

module Mobile::Graph::Types
  class VersionRequirementType < BaseObject
    field :min_required_version, String, null: false
    field :min_required_build, String, null: false
    field :min_recommended_version, String, null: false
    field :min_recommended_build, String, null: false
  end
end
