# frozen_string_literal: true

class SpamChecks::Activity::Base
  attr_reader :record, :request_info
  attr_accessor :action_log

  def initialize(activity_record, request_info)
    @record = activity_record
    @request_info = request_info
  end

  def actor
    raise NotImplementedError
  end

  def mark_as_spam
    raise NotImplementedError
  end

  def revert_action_taken
    raise NotImplementedError
  end

  def skip_spam_check?
    raise NotImplementedError
  end
end
