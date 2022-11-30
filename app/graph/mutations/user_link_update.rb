# frozen_string_literal: true

module Graph::Mutations
  class UserLinkUpdate < BaseMutation
    argument :id, ID, required: true
    argument :name, String, required: true
    argument :url, String, required: true

    returns Graph::Types::UserLinkType

    require_current_user

    def perform(inputs)
      link = current_user.links.find(inputs[:id])
      link.update!(name: inputs[:name], url: inputs[:url], kind: inputs[:kind])

      link
    end
  end
end
