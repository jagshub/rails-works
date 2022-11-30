# frozen_string_literal: true

module Graph::Mutations
  class UserLinkDestroy < BaseMutation
    argument :id, ID, required: true

    returns Graph::Types::UserLinkType
    require_current_user

    def perform(inputs)
      link = current_user.links.find(inputs[:id])
      link.destroy!
      link
    end
  end
end
