# frozen_string_literal: true

module SpamChecks::Filters::NewUserFilter
  extend self

  def check(filter_input)
    user = user_from_activity(filter_input.record)
    return filter_input.false_result if user.blank?

    spam = user.created_at > 7.days.ago

    filter_input.result(
      is_spam: spam,
      checked_data: { user_created_at: user.created_at },
    )
  end

  private

  def user_from_activity(activity)
    case activity
    when User
      activity
    else
      raise ArgumentError, "#{ activity.class.name } is not handled by the filter" unless activity.respond_to?(:user)

      activity.user
    end
  end
end
