# frozen_string_literal: true

module SpamChecks::Admin::UserMarkAsBadActor
  extend self

  def call(user, handled_by, activity, reason)
    ActiveRecord::Base.transaction do
      user.bad_actor!

      take_action_on_activity(activity) if activity.present?

      Spam::ManualLog.create!(
        action: 'mark_as_bad_actor',
        activity: activity,
        user: user,
        handled_by: handled_by,
        reason: reason,
      )

      UserMailer.account_suspended(user).deliver_later if user.email.present?
    end
  end

  private

  # Note(Rahul): Other than post everything else should be hidden
  def take_action_on_activity(activity)
    if activity.is_a? Post
      activity.trash
    else
      activity.hide!
    end
  end
end
