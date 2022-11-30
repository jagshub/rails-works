# frozen_string_literal: true

module Spam::User::MarkAsSpammer
  extend self

  ACTIONS = %i(
    hide_comments
    update_role
    mark_votes
    remove_product_makers
    remove_goals
    remove_discussions
  ).freeze

  def mark(user, **log)
    log[:actions] = ACTIONS if log[:actions].blank?

    ActiveRecord::Base.transaction do
      spam_log = Spam.log_entity(
        user: user,
        entity: user,
        kind: log[:kind],
        level: log[:level],
        action: :mark_as_spam,
        current_user: log[:current_user],
        parent_log_id: log[:parent_log_id],
        remarks: log[:remarks],
        more_information: { actions: log[:actions], role: log[:role] },
      )

      # NOTE(naman): spam_log is nil if the parent_log does not exist
      return if spam_log.blank?

      log[:actions].each { |action| perform_action(user, action, log, spam_log.id) }
    end
  end

  def unmark(user, **log)
    ActiveRecord::Base.transaction do
      spam_log = Spam.log_entity(
        user: user,
        entity: user,
        kind: log[:kind],
        level: log[:level],
        action: :unmark_as_spam,
        current_user: log[:current_user],
        parent_log_id: log[:parent_log_id],
        remarks: log[:remarks],
      )

      update(user, :user)
      Voting::PostVoteModeration.unmark_votes(
        user,
        remarks: 'Vote is unmarked as non-credible and sandboxed. Check parent log for more info.',
        kind: log[:kind],
        level: log[:level],
        current_user: log[:current_user],
        parent_log_id: spam_log.id,
      )
    end
  end

  private

  def update(user, role)
    allowed_roles = %w(user).concat(Spam::User::NON_CREDIBLE_ROLES)
    raise ArgumentError, "Role provided is not allowed. Permitted roles are : #{ allowed_roles.join(', ') }" unless allowed_roles.include?(role.to_s)

    user.update! role: role
  end

  def remove_product_makers(user)
    user.product_makers.destroy_all
  end

  def remove_goals(user)
    user.goals.destroy_all
  end

  def remove_discussions(user)
    user.discussion_threads.destroy_all
  end

  def perform_action(user, action, log, parent_log_id = nil)
    case action
    when :hide_comments
      Spam::HideCommentsWorker.perform_later(
        user: user,
        current_user: log[:current_user],
        parent_log_id: parent_log_id,
        kind: log[:kind].to_s,
        level: log[:level].to_s,
      )
    when :update_role
      update(user, log[:role])
    when :mark_votes
      Voting::PostVoteModeration.mark_votes(
        user,
        remarks: 'Vote is marked as non-credible. Check parent log for more info.',
        kind: log[:kind],
        level: log[:level],
        current_user: log[:current_user],
        parent_log_id: parent_log_id,
      )
    when :remove_product_makers then remove_product_makers(user)
    when :remove_goals then remove_goals(user)
    when :remove_discussions then remove_discussions(user)
    else raise ArgumentError, 'Action provided is unknown'
    end
  end
end
