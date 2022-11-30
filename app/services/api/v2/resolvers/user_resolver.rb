# frozen_string_literal: true

module API::V2::Resolvers
  class UserResolver < BaseResolver
    argument :id, ID, 'ID for the user.', required: false
    argument :username, String, 'Username for the user.', required: false

    def resolve(id: nil, username: nil)
      param = id.present? ? { id: id } : { username: username&.downcase }
      User.find_by(param)
    end
  end
end
