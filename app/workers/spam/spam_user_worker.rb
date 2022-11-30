# frozen_string_literal: true

class Spam::SpamUserWorker < ApplicationJob
  include ActiveJobHandlePostgresErrors

  def perform(log, actions: [], role: nil)
    if actions.include?('update_role') || actions.blank?
      role ||= 'spammer'
    elsif role.present?
      actions.push('update_role')
    end

    Spam::User.mark(
      log[:user],
      role: role,
      kind: log[:kind].to_sym,
      level: log[:level].to_sym,
      remarks: log[:remarks] || 'User is marked as spam, check parent log for more info.',
      current_user: log[:current_user],
      parent_log_id: log[:parent_log_id],
      actions: actions.map(&:to_sym),
    )
  end
end
