# frozen_string_literal: true

class API::Widgets::Cards::V1::UserSerializer < BaseSerializer
  self.root = false

  delegated_attributes :id, :name, :headline, :username, to: :resource
end
