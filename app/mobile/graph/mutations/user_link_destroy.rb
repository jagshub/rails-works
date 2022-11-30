# frozen_string_literal: true

module Mobile::Graph::Mutations
  class UserLinkDestroy < BaseMutation
    argument :link_id, ID, required: true

    returns Mobile::Graph::Types::UserLinkType
    require_current_user

    def perform(inputs)
      link = current_user.links.find(inputs[:link_id])
      link.destroy!
      link
    end
  end
end
