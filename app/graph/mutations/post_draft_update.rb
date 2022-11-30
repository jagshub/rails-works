# frozen_string_literal: true

module Graph::Mutations
  class PostDraftUpdate < BaseMutation
    argument :uuid, String, required: true
    argument :data, Graph::Types::JsonType, required: true

    returns Graph::Types::PostDraftType

    require_current_user

    def perform(uuid:, data: {})
      draft = PostDraft.find_by!(uuid: uuid, user_id: context[:current_user].id)
      return unless draft

      draft.update!(data: data)
      draft
    end
  end
end
