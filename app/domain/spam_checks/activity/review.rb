# frozen_string_literal: true

class SpamChecks::Activity::Review < SpamChecks::Activity::Base
  def initialize(review, request_info)
    super(review, request_info)
  end

  def actor
    @record.user
  end

  def mark_as_spam
    @record.hide!
  end

  def revert_action_taken
    @record.unhide!
  end

  def skip_spam_check?
    false
  end
end
