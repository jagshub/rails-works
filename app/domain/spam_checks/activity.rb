# frozen_string_literal: true

module SpamChecks::Activity
  extend self

  def build(action, request_info = nil)
    activity_class = FindConst.call(SpamChecks::Activity, action)

    activity_class.new(
      action,
      request_info,
    )
  end

  def mark_as_spam(action)
    build(action).mark_as_spam
  end

  def revert_action_taken(action)
    build(action).revert_action_taken
  end
end
