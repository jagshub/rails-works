# frozen_string_literal: true

class Maker::GroupMembers::RemindWorker < ApplicationJob
  include ActiveJobHandleDeserializationError
  include ActiveJobHandleMailjetErrors

  queue_as :mailers

  def perform(member:, **_args)
    return unless member.group.main?
    return if member.user.email.blank?

    return if member.user.onboardings.maker.finished.exists?

    MakerMailer
      .remind_group_member(member)
      .deliver_now
  end
end
