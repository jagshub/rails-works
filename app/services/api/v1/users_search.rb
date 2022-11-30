# frozen_string_literal: true

class API::V1::UsersSearch
  include SearchObject.module
  include API::V1::Sorting

  scope { User }

  sort_by :id, :created_at, :updated_at
end
