# frozen_string_literal: true

class Maker::GroupMembers::NotifyWorker < ApplicationJob
  include ActiveJobHandleDeserializationError
  include ActiveJobHandleNetworkErrors

  queue_as :mailers

  def perform(member:, member_changes: ActiveSupport::HashWithIndifferentAccess.new, **_args)
    return unless member.accepted?
    return unless state_changed_to_accepted? member_changes

    send_group_mail member
    send_main_group_mail member
    send_notification member
    schedule_main_group_reminder_mail member
  end

  private

  def state_changed_to_accepted?(changes)
    prev_state, next_state = changes[:state]

    return false if prev_state == next_state

    next_state == 'accepted'
  end

  def send_group_mail(member)
    return unless member.assessed?
    return unless member.group.accessible?
    return if member.user.email.blank?

    MakerMailer
      .accepted_group_member(member)
      .deliver_now
  end

  def send_main_group_mail(member)
    return unless member.group.main?
    return if member.user.email.blank?

    MakerMailer
      .welcome(member)
      .deliver_now
  end

  def send_notification(member)
    Notifications
      .notify_about(kind: 'maker_accepted_group_member', object: member)
  end

  def schedule_main_group_reminder_mail(member)
    return unless member.group.main?
    return if member.user.email.blank?

    Maker::GroupMembers::RemindWorker
      .set(wait: 1.week)
      .perform_later(member: member)
  end
end
