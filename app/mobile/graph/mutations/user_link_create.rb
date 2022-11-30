# frozen_string_literal: true

module Mobile::Graph::Mutations
  class UserLinkCreate < BaseMutation
    argument :name, String, required: true
    argument :url, String, required: true

    returns Mobile::Graph::Types::UserLinkType

    require_current_user

    def perform(inputs)
      current_user.links.create(name: inputs[:name], url: inputs[:url])
    end
  end
end
