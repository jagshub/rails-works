# frozen_string_literal: true

module Graph::Mutations
  class UserLinkCreate < BaseMutation
    argument :name, String, required: true
    argument :url, String, required: true

    returns Graph::Types::UserLinkType

    require_current_user

    def perform(inputs)
      current_user.links.create(name: inputs[:name], url: inputs[:url])
    end
  end
end
