# frozen_string_literal: true

module Graph::Mutations
  class PostDraftDestroy < BaseMutation
    argument :uuid, String, required: true

    returns Graph::Types::PostDraftType

    require_current_user

    def perform(uuid:)
      draft = PostDraft.find_by!(uuid: uuid, post_id: nil, user_id: current_user.id)
      draft.destroy!
    end
  end
end
