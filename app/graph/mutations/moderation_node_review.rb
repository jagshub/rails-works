# frozen_string_literal: true

module Graph::Mutations
  class ModerationNodeReview < BaseMutation
    argument_record :subject, [Discussion::Thread], authorize: :moderate

    returns Graph::Types::Discussion::ThreadType

    def perform(subject:)
      Moderation.mark_as_reviewed by: current_user, reference: subject
      subject
    end
  end
end
