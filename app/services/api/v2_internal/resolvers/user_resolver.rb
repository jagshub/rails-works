# frozen_string_literal: true

class API::V2Internal::Resolvers::UserResolver < Graph::Resolvers::Base
  argument :id, ID, required: false
  argument :username, String, required: false

  type API::V2Internal::Types::UserType, null: true

  def resolve(args = {})
    id = args[:id]
    username = args[:username]
    param = id.present? ? { id: id } : { username: username&.downcase }

    User.find_by(param)
  end
end
