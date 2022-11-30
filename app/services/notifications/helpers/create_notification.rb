# frozen_string_literal: true

module Notifications::Helpers::CreateNotification
  extend self

  def call(kind:, object:, subscriber_id:)
    notifyable = Notifications::Notifiers.for(kind).extract_notifyable(object)
    NotificationLog.create!(
      subscriber_id: subscriber_id,
      kind: NotificationLog.kinds.fetch(kind),
      notifyable: notifyable,
    )
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    # Note(andreasklinger): We intentionally use Postgres (not rails) as safety-check because it can act atomic.
    nil
  end
end
