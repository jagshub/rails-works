# frozen_string_literal: true

class API::V1::OAuthUserInfoSerializer < API::V1::BaseSerializer
  delegated_attributes :id, :name, :email, :first_name, :last_name, to: :resource

  attributes :picture

  def picture
    Users::Avatar.url_for_user(resource, size: 'original')
  end
end
