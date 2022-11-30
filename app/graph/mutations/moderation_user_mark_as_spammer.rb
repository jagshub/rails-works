# frozen_string_literal: true

module Graph::Mutations
  class ModerationUserMarkAsSpammer < BaseMutation
    argument_record :user, User, authorize: :moderate, required: true
    argument :activity_id, ID, required: false
    argument :activity_type, Graph::Types::SpamManualLogActivityType, required: false
    argument :reason, String, required: false

    returns Graph::Types::UserType

    def perform(user:, activity_id: nil, activity_type: nil, reason: nil)
      return user if user.spammer?

      SpamChecks.mark_user_as_spammer(
        user: user,
        handled_by: current_user,
        reason: reason,
        activity: find_activity(activity_id, activity_type),
      )

      user
    end

    private

    def find_activity(id, type)
      return if id.blank? || type.blank?

      Spam::ManualLog.find_subject_from_type graph_type: type, id: id
    end
  end
end
