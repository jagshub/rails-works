# frozen_string_literal: true

class API::V1::VotesSearch
  include SearchObject.module
  include API::V1::Sorting

  sort_by :id, :created_at, :updated_at
end
