# frozen_string_literal: true

module Graph::Mutations
  class ModerationDuplicatePostRequestAction < BaseMutation
    argument_record :request, ::Moderation::DuplicatePostRequest, required: true, authorize: :edit
    argument :approve, Boolean, required: true

    returns Boolean

    def perform(request:, approve:)
      if approve
        Moderation::DuplicatePost.approve_request(request, current_user)
      else
        Moderation::DuplicatePost.reject_request(request, current_user)
      end

      true
    end
  end
end
