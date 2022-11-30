# frozen_string_literal: true

class SpamChecks::Activity::Comment < SpamChecks::Activity::Base
  def initialize(comment, request_info)
    super(comment, request_info)
  end

  def actor
    @record.user
  end

  def mark_as_spam
    @record.trash
  end

  def revert_action_taken
    @record.restore
  end

  def skip_spam_check?
    return true if @record.hidden?
    return true if legit_user_role?(@record.user)

    false
  end

  private

  LEGIT_ROLES = %w(can_post admin).freeze

  def legit_user_role?(user)
    LEGIT_ROLES.include? user.role
  end
end
